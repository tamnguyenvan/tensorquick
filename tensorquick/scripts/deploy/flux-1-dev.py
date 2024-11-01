# ---
# output-directory: "/tmp/flux"
# args: ["--no-compile"]
# tags: ["use-case-image-video-3d", "featured"]
# ---

# # Run Flux fast with `torch.compile` on Hopper GPUs

# In this guide, we'll run Flux as fast as possible on Modal using open source tools.
# We'll use `torch.compile` and NVIDIA H100 GPUs.

# ## Setting up the image and dependencies

import os
import time
from io import BytesIO
from pathlib import Path

import modal
from fastapi import Response, HTTPException
from pydantic import BaseModel

# We'll make use of the full [CUDA toolkit](https://modal.com/docs/guide/cuda)
# in this example, so we'll build our container image off of the `nvidia/cuda` base.

cuda_version = "12.4.0"  # should be no greater than host CUDA version
flavor = "devel"  # includes full CUDA toolkit
operating_sys = "ubuntu22.04"
tag = f"{cuda_version}-{flavor}-{operating_sys}"
hf_readonly_token = "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"
variant = "dev"  # or "dev", but note [dev] requires you to accept terms and conditions on HF

cuda_dev_image = modal.Image.from_registry(
    f"nvidia/cuda:{tag}", add_python="3.11"
).entrypoint([])

# Now we install most of our dependencies with `apt` and `pip`.
# For Hugging Face's [Diffusers](https://github.com/huggingface/diffusers) library
# we install from GitHub source and so pin to a specific commit.

# PyTorch added [faster attention kernels for Hopper GPUs in version 2.5

diffusers_commit_sha = "81cf3b2f155f1de322079af28f625349ee21ec6b"

flux_image = cuda_dev_image.apt_install(
    "git",
    "libglib2.0-0",
    "libsm6",
    "libxrender1",
    "libxext6",
    "ffmpeg",
    "libgl1",
).pip_install(
    "invisible_watermark==0.2.0",
    "transformers==4.44.0",
    "accelerate==0.33.0",
    "safetensors==0.4.4",
    "sentencepiece==0.2.0",
    "torch==2.5.0",
    f"git+https://github.com/huggingface/diffusers.git@{diffusers_commit_sha}",
    "numpy<2",
)

# Later, we'll also use `torch.compile` to increase the speed further.
# Torch compilation needs to be re-executed when each new container starts,
# So we turn on some extra caching to reduce compile times for later containers.

flux_image = flux_image.env({
    "TORCHINDUCTOR_CACHE_DIR": "/root/.inductor-cache",
    "TORCHINDUCTOR_FX_GRAPH_CACHE": "1",
})
# Finally, we construct our Modal [App](https://modal.com/docs/reference/modal.App),
# set its default image to the one we just constructed,
# and import `FluxPipeline` for downloading and running Flux.1.

app = modal.App(f"flux-1-{variant}", image=flux_image)

with flux_image.imports():
    import torch
    from diffusers import FluxPipeline

# ## Defining a parameterized `Model` inference class

# Next, we map the model's setup and inference code onto Modal.

# 1. We run any setup that can be persisted to disk in methods decorated with `@build`.
# In this example, that includes downloading the model weights.
# 2. We run any additional setup, like moving the model to the GPU, in methods decorated with `@enter`.
# We do our model optimizations in this step. For details, see the section on `torch.compile` below.
# 3. We run the actual inference in methods decorated with `@method`.

MINUTES = 60  # seconds
NUM_INFERENCE_STEPS = 20  # use ~50 for [dev], smaller for [schnell]
TENSOR_QUICK_GPU_TYPE = "H100"

class GenerationRequest(BaseModel):
    prompt: str

@app.cls(
    gpu=TENSOR_QUICK_GPU_TYPE,
    container_idle_timeout=1 * MINUTES,
    timeout=1 * MINUTES,
    volumes={  # add Volumes to store serializable compilation artifacts, see section on torch.compile below
        "/root/.nv": modal.Volume.from_name("nv-cache", create_if_missing=True),
        "/root/.triton": modal.Volume.from_name(
            "triton-cache", create_if_missing=True
        ),
        "/root/.inductor-cache": modal.Volume.from_name(
            "inductor-cache", create_if_missing=True
        ),
    },
    secrets=[modal.Secret.from_dict({"HF_TOKEN": hf_readonly_token})]
)
class Model:
    compile: int = (  # see section on torch.compile below for details
        modal.parameter(default=0)
    )

    def setup_model(self):
        from huggingface_hub import snapshot_download
        from transformers.utils import move_cache

        snapshot_download(f"black-forest-labs/FLUX.1-{variant}")

        move_cache()

        pipe = FluxPipeline.from_pretrained(
            f"black-forest-labs/FLUX.1-{variant}", torch_dtype=torch.bfloat16
        )

        return pipe

    @modal.build()
    def build(self):
        self.setup_model()

    @modal.enter()
    def enter(self):
        pipe = self.setup_model()
        pipe.to("cuda")  # move model to GPU
        self.pipe = pipe

    @modal.method()
    def inference(self, prompt: str) -> bytes:
        print("🎨 generating image...")
        out = self.pipe(
            prompt,
            output_type="pil",
            num_inference_steps=NUM_INFERENCE_STEPS,
        ).images[0]

        byte_stream = BytesIO()
        out.save(byte_stream, format="JPEG")
        return byte_stream.getvalue()

    @modal.web_endpoint(method="POST")
    async def web_inference(
        self,
        request: GenerationRequest,
    ) -> Response:
        # Generate image
        try:
            out = self.pipe(
                request.prompt,
                output_type="pil",
                num_inference_steps=NUM_INFERENCE_STEPS,
            ).images[0]

            byte_stream = BytesIO()
            out.save(byte_stream, format="JPEG")
            return Response(
                content=byte_stream.getvalue(),
                media_type="image/jpeg"
            )
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error in generation process: {str(e)}"
            )