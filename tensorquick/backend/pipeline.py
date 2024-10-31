import os
import tempfile
import shutil
from datetime import datetime
from typing import Optional, Tuple
from loguru import logger

import requests
from PIL import Image
from PySide6.QtCore import QObject, Slot, Signal, Property, QThread

from tensorquick.backend.clipboard import ClipboardModel
from tensorquick.backend.types import GenerationResult, WorkerStatus
from tensorquick.utils.general import validate_image_path
from tensorquick.config import default_settings

class ImageProcessor:
    """Handles image processing operations like saving, copying, and validation"""

    def __init__(self):
        self._clipboard_model = ClipboardModel()
        self._save_dir = os.path.expanduser(default_settings["save_dir"])

    def save_and_show(self, image_path: str) -> Tuple[bool, str]:
        """
        Saves the image and opens it in default viewer

        Args:
            image_path: Path to the image file

        Returns:
            Tuple of (success, error_message)
        """
        try:
            is_valid, error = validate_image_path(image_path)
            if not is_valid:
                return False, error

            if not os.path.exists(self._save_dir):
                os.makedirs(self._save_dir, exist_ok=True)

            filename = os.path.basename(image_path)
            new_image_path = os.path.join(self._save_dir, filename)
            shutil.copy(image_path, new_image_path)
            image = Image.open(new_image_path)
            image.show()
            return True, ""

        except Exception as e:
            error_msg = f"Error viewing image: {str(e)}"
            logger.error(error_msg, exc_info=True)
            return False, error_msg

    def copy_to_clipboard(self, image_path: str) -> Tuple[bool, str]:
        """
        Copies the image to system clipboard

        Args:
            image_path: Path to the image file

        Returns:
            Tuple of (success, error_message)
        """
        return self._clipboard_model.copyImageToClipboard(image_path)

class InferencePipeline(QObject):
    """Main pipeline for image inference"""
    imagePathChanged = Signal(str)
    currentModelChanged = Signal(dict)
    loadingChanged = Signal(bool)
    progressChanged = Signal(int)
    generationCompleted = Signal(bool, str, str)
    errorOccurred = Signal(str)

    def __init__(self, current_model: dict = None) -> None:
        super().__init__()
        self._current_model = current_model
        self._image_path: str = ""
        self._loading: bool = False
        self._worker: Optional[ImageGeneratorWorker] = None
        self._image_processor = ImageProcessor()

    @Property(str, notify=imagePathChanged)
    def imagePath(self) -> str:
        return self._image_path

    @Property(bool, notify=loadingChanged)
    def loading(self) -> bool:
        return self._loading

    @Property(dict, notify=currentModelChanged)
    def currentModel(self):
        return self._current_model

    @currentModel.setter
    def currentModel(self, model):
        self._current_model = model
        self.currentModelChanged.emit(model)

    def _onGenerationComplete(self, result: GenerationResult) -> None:
        self._loading = False
        self.loadingChanged.emit(False)

        if result.success:
            self._image_path = result.image_path
            self.imagePathChanged.emit(self._image_path)
            self.generationCompleted.emit(True, result.image_path, "")
        else:
            self.errorOccurred.emit(result.error_message or "Unknown error occurred")
            self.generationCompleted.emit(True, "", result.error_message)

        if self._worker:
            self._worker.deleteLater()
            self._worker = None

    def _onProgressUpdate(self, progress: int) -> None:
        self.progressChanged.emit(progress)

    @Slot(str)
    def generateImage(self, prompt: str) -> None:
        """Start image generation process"""
        try:
            if self._worker and self._worker.status == WorkerStatus.RUNNING:
                logger.warning("Generation already in progress")
                return

            current_model = self._current_model
            if not current_model or not current_model["deployed_url"]:
                logger.warning("No deployed model")
                return

            self._loading = True
            self.loadingChanged.emit(True)

            self._worker = ImageGeneratorWorker(current_model["deployed_url"], prompt)
            self._worker.finished.connect(self._onGenerationComplete)
            self._worker.progress.connect(self._onProgressUpdate)
            self._worker.start()

        except Exception as e:
            logger.error(f"Error starting generation: {str(e)}", exc_info=True)
            self._loading = False
            self.loadingChanged.emit(False)
            self.errorOccurred.emit(str(e))

    @Slot()
    def saveImage(self) -> None:
        """Save the generated image and open it in default viewer"""
        success, error = self._image_processor.save_and_show(self._image_path)
        if not success:
            self.errorOccurred.emit(error)

    @Slot()
    def copyImageToClipboard(self) -> None:
        """Copy the generated image to clipboard"""
        success, error = self._image_processor.copy_to_clipboard(self._image_path)
        if not success:
            self.errorOccurred.emit(error)

    @Slot()
    def copyDeployedUrlToClipboard(self) -> None:
        """Copy the deployed to clipboard"""
        ClipboardModel().copyTextToClipboard(self._current_model["deployed_url"])

class ImageGeneratorWorker(QThread):
    """Worker thread for image generation"""
    finished = Signal(GenerationResult)
    progress = Signal(int)  # 0-100

    def __init__(self, model_url: str, prompt: str) -> None:
        super().__init__()
        self._model_url = model_url
        self._prompt = prompt
        self._status = WorkerStatus.IDLE

    @property
    def status(self) -> WorkerStatus:
        return self._status

    def _get_extension_from_mime(self, content_type: str) -> str:
        """Get file extension from MIME type"""
        mime_to_ext = {
            'image/jpeg': '.jpg',
            'image/jpg': '.jpg',
            'image/png': '.png',
            'image/gif': '.gif',
            'image/webp': '.webp',
            'image/svg+xml': '.svg'
        }
        # Convert to lowercase and strip any parameters
        content_type = content_type.lower().split(';')[0].strip()
        return mime_to_ext.get(content_type, '.jpg')  # Default to .jpg if not found

    def _inference(self, prompt):
        try:
            json_data = {"prompt": prompt}
            response = requests.post(self._model_url, json=json_data)
            if response.ok:
                return response, response.content
            else:
                logger.error(f"Error: {response.text}")
                return None, None
        except Exception as e:
            logger.error(f"Failed to run model: {str(e)}")
            return None, None

    def run(self) -> None:
        try:
            self._status = WorkerStatus.RUNNING
            logger.info(f"Starting image generation for prompt: {self._prompt}")

            # response, image_bytes = self._inference(self._prompt)
            # if not image_bytes:
            #     self._status = WorkerStatus.ERROR
            #     self.finished.emit(GenerationResult(False, "", "Failed to inference"))
            #     return

            # # Get file extension from response content-type
            # if response and 'content-type' in response.headers:
            #     extension = self._get_extension_from_mime(response.headers['content-type'])
            # else:
            #     extension = '.jpg'  # Default extension
            #     logger.warning("Content-type not found in response, using default extension .jpg")

            # # Create temp directory if it doesn't exist
            # temp_dir = tempfile.gettempdir()
            # if not os.path.exists(temp_dir):
            #     os.makedirs(temp_dir, exist_ok=True)

            # # Generate unique filename with proper extension
            # app_name = default_settings.get("app")
            # timestamp = int(datetime.now().timestamp())
            # temp_file = f"{self._prompt}-{app_name}-{timestamp}{extension}"
            # generated_image_path = os.path.join(temp_dir, temp_file)

            # # Save the image
            # with open(generated_image_path, "wb") as f:
            #     f.write(image_bytes)

            import time
            time.sleep(2)
            generated_image_path = "/home/tamnv/Downloads/ohmyicon-a-plum.jpg"
            self._status = WorkerStatus.COMPLETED
            self.finished.emit(GenerationResult(True, generated_image_path, ""))

        except Exception as e:
            logger.error(f"Error in image generation: {str(e)}", exc_info=True)
            self._status = WorkerStatus.ERROR
            self.finished.emit(GenerationResult(False, "", error_message=str(e)))
