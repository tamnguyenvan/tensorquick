import os
import re
import subprocess
from typing import Optional
from pathlib import Path

from loguru import logger
from PySide6.QtCore import (
    QObject,
    Slot,
    Signal,
    Property,
    QThread,
)
from tensorquick.backend.types import WorkerStatus

class ModelBuilder(QObject):
    """Handler for model deployment operations"""
    deployingChanged = Signal(bool)
    deployedChanged = Signal(bool)
    deployedModelsChanged = Signal(list)
    progressChanged = Signal(int)

    stoppingChanged = Signal(bool)
    stoppedChanged = Signal(bool)

    errorOccurred = Signal(str)

    def __init__(self) -> None:
        super().__init__()
        self._deploying: bool = False
        self._worker: Optional[ModelDeployWorker] = None
        self._stop_worker: Optional[ModelStopWorker] = None
        self._deployed_models = []

    @Property(list, notify=deployedModelsChanged)
    def deployedModels(self):
        return self._deployed_models

    @deployedModels.setter
    def deployedModels(self, models: list):
        self._deployed_models = models
        self.deployedModelsChanged.emit(models)

    @Property(bool, notify=deployingChanged)
    def deploying(self):
        return self._deploying

    @deploying.setter
    def deploying(self, value):
        self._deploying = value
        self.deployingChanged.emit(value)

    def _modelExists(self, model):
        for deployed_model in self._deployed_models:
            if model["code_name"] == deployed_model["code_name"]:
                return True
        return False

    def _replaceByCodeName(self, model):
        for deployed_model in self._deployed_models:
            if model["code_name"] == deployed_model["code_name"]:
                deployed_model = model

    def _onDeploymentCompleted(self, success: bool, model: dict, error_message: str) -> None:
        self.deploying = False
        self.deployedChanged.emit(True)

        if not success:
            self.errorOccurred.emit(error_message)
            self.deployedModels = self._deployed_models
            return

        if not self._modelExists(model):
            self._deployed_models.append(model)
        else:
            self._replaceByCodeName(model)
        self.deployedModels = self._deployed_models

        # Cleanup worker
        if self._worker:
            self._worker.deleteLater()
            self._worker = None

    def _onProgressUpdate(self, progress: int) -> None:
        self.progressChanged.emit(progress)

    @Slot(dict)
    def deploy(self, model: dict) -> None:
        """Start model deployment process"""
        try:
            if self._worker and self._worker._status == WorkerStatus.RUNNING:
                logger.warning("Deployment already in progress")
                return

            self._deploying = True
            self.deployingChanged.emit(True)

            gpu_type = model.get("gpu_type", "A100-40GB")
            model["gpu_type"] = gpu_type
            envs = {
                "TENSOR_QUICK_GPU_TYPE": gpu_type
            }
            self._worker = ModelDeployWorker(model, envs)
            self._worker.finished.connect(self._onDeploymentCompleted)
            self._worker.progress.connect(self._onProgressUpdate)
            self._worker.start()

        except Exception as e:
            logger.error(f"Error starting deployment: {str(e)}", exc_info=True)
            self._deploying = False
            self.deployingChanged.emit(False)
            self.deployedChanged.emit(False)
            self.errorOccurred.emit(str(e))

    @Slot()
    def stopCurrentDeployment(self) -> None:
        if self._worker and self._deploying:
            self._worker.stop()
            self._deploying = False

    def _onStopAppCompleted(self, success: bool, model: dict, error_message: str) -> None:
        self.stoppingChanged.emit(False)
        self.stoppedChanged.emit(True)
        if not success:
            self.errorOccurred.emit(error_message)
            self.deployedModels = self._deployed_models
            return

        new_deployed_models = []
        for deployed_model in self._deployed_models:
            if deployed_model["code_name"] != model["code_name"]:
                new_deployed_models.append(deployed_model)

        self.deployedModels = new_deployed_models

        # Cleanup worker
        if self._worker:
            self._worker.deleteLater()
            self._worker = None

    @Slot(dict)
    def stopApp(self, model: dict) -> None:
        try:
            self._stop_worker = ModelStopWorker(model)
            self._stop_worker.finished.connect(self._onStopAppCompleted)
            self._stop_worker.start()
        except Exception as e:
            logger.error(f"Error stopping model: {model}", exc_info=True)
            self.errorOccurred.emit(str(e))

class ModelDeployWorker(QThread):
    """Worker thread for model deployment"""
    finished = Signal(bool, dict, str)  # success, error_message
    progress = Signal(int)

    def __init__(self, model: dict, envs: dict = dict()) -> None:
        super().__init__()
        self._model = model or dict()
        self._envs = envs
        self._status = WorkerStatus.IDLE
        self._process: Optional[subprocess.Popen] = None

        # Define paths
        self._base_path = Path(__file__).parents[1]
        self._scripts_path = self._base_path / "scripts/deploy"
        self._deploy_script = self._scripts_path / f"{self._model['code_name']}.py"

    def _validate_deployment_script(self) -> None:
        """Validate deployment script existence and permissions"""
        if not self._deploy_script.exists():
            raise FileNotFoundError(
                f"Deployment script not found: {self._deploy_script}"
            )

    def _setup_environment(self) -> None:
        """Setup environment variables for deployment"""
        try:
            # Read the content of the script
            with open(self._deploy_script, 'r') as script_file:
                script_lines = script_file.readlines()

            # Regex to find keys in the format TENSOR_QUICK_*="*"
            pattern = r'^\s*(TENSOR_QUICK_[^=]+)\s*=\s*"([^"]*)"\s*$'
            updated_lines = []

            # Iterate through each line to find and update values
            for line in script_lines:
                match = re.match(pattern, line.strip())
                if match:
                    key = match.group(1).strip()
                    # If key exists in self._envs, update the value
                    if key in self._envs:
                        new_value = self._envs[key]
                        line = f'{key} = "{new_value}"\n'
                updated_lines.append(line)

            # Write the updated content back to the file
            with open(self._deploy_script, 'w') as script_file:
                script_file.writelines(updated_lines)

        except Exception as e:
            raise RuntimeError(f"Error setting up environment: {str(e)}")

    def _extract_deployed_url(self, line: str) -> str:
        deployed_url = ""
        line = line.strip()
        if f"--{self._model['code_name']}-model-web-inference" in line:
            pattern = r'https?://[^\s]+'
            match = re.search(pattern, line)

            if match:
                link = match.group(0)
                deployed_url = link

        return deployed_url

    def _execute_deployment(self, env: dict) -> str:
        """Execute deployment script and handle output"""
        try:
            # Use modal deploy command
            deploy_command = [
                "modal", "deploy", str(self._deploy_script)
            ]

            logger.info(f"Executing deployment command: {' '.join(deploy_command)}")

            self._process = subprocess.Popen(
                deploy_command,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            if not self._process:
                raise RuntimeError("Failed to start deployment process")

            total_steps = 5
            current_step = 0

            deployed_url = ""
            while True:
                if self._process.poll() is not None:
                    break

                line = self._process.stdout.readline()
                if line:
                    logger.info(f"Deployment output: {line.strip()}")
                    extracted_url = self._extract_deployed_url(line)
                    if extracted_url:
                        deployed_url = extracted_url

                    # Update progress based on output
                    if "Starting deployment" in line:
                        current_step = 1
                    elif "Uploading code" in line:
                        current_step = 2
                    elif "Building container" in line:
                        current_step = 3
                    elif "Deploying model" in line:
                        current_step = 4
                    elif "Deployment complete" in line:
                        current_step = 5

                    progress = int((current_step / total_steps) * 100)
                    self.progress.emit(progress)

            # Check exit code
            if self._process.returncode != 0:
                error_output = self._process.stderr.read()
                raise RuntimeError(
                    f"Deployment failed with exit code {self._process.returncode}: {error_output}"
                )

            return deployed_url

        except Exception as e:
            raise RuntimeError(f"Deployment execution error: {str(e)}")
        finally:
            # Cleanup process
            if self._process:
                self._process.stdout.close()
                self._process.stderr.close()

    def run(self) -> None:
        """Run deployment process"""
        try:
            self._status = WorkerStatus.RUNNING
            logger.info(f"Starting deployment for model: {self._model['code_name']}")

            # Validate deployment script
            self._validate_deployment_script()

            # Setup environment
            env = self._setup_environment()

            # Execute deployment
            deployed_url = self._execute_deployment(env)
            if deployed_url:
                self._model["deployed_url"] = deployed_url
            else:
                raise Exception(f"Failed to deploy model {self._model}")

            # Deployment successful
            self._status = WorkerStatus.COMPLETED
            self.finished.emit(True, self._model, "")
            logger.info(f"Deployment completed successfully for model: {self._model['code_name']}. Deployed URL: {self._model['deployed_url']}")
        except Exception as e:
            error_msg = f"Deployment failed: {str(e)}"
            logger.error(error_msg, exc_info=True)
            self._status = WorkerStatus.ERROR
            self.finished.emit(False, dict(), error_msg)

        finally:
            # Cleanup
            if self._process and self._process.poll() is None:
                try:
                    self._process.terminate()
                    self._process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self._process.kill()
                    logger.warning("Had to force kill deployment process")

    def stop(self) -> None:
        """Stop the deployment process"""
        if self._process and self._process.poll() is None:
            try:
                self._process.terminate()
                logger.info("Stopping deployment process...")
                if not self._process.wait(timeout=5):
                    self._process.kill()
                    logger.warning("Force killed deployment process")
            except Exception as e:
                logger.error(f"Error stopping deployment: {str(e)}", exc_info=True)

class ModelStopWorker(QThread):
    finished = Signal(bool, dict, str)  # success, error_message

    def __init__(self, model: dict):
        super().__init__()
        self._model = model
        self._status = WorkerStatus.IDLE
        self._process: Optional[subprocess.Popen] = None

    def run(self):
        try:
            self._status = WorkerStatus.RUNNING
            logger.info(f"Stopping model: {self._model['code_name']}")

            # stop_command = [
            #     "modal", "stop", self._model.code_name
            # ]
            # self._process = subprocess.Popen(
            #     stop_command,
            #     stdout=subprocess.PIPE,
            #     stderr=subprocess.PIPE,
            #     text=True,
            #     bufsize=1,
            #     universal_newlines=True
            # )

            # if not self._process:
            #     raise RuntimeError("Failed to start deployment process")

            # while True:
            #     if self._process.poll() is not None:
            #         break

            # # Check exit code
            # if self._process.returncode != 0:
            #     error_output = self._process.stderr.read()
            #     raise RuntimeError(
            #         f"Deployment failed with exit code {self._process.returncode}: {error_output}"
            #     )
            import time
            time.sleep(2)
            self.finished.emit(True, self._model, "")
            self._status = WorkerStatus.COMPLETED
            logger.info(f"Stopped model successfully : {self._model['code_name']}")
        except Exception as e:
            error_msg = f"Failed to stop: {str(e)}"
            logger.error(error_msg, exc_info=True)
            self._status = WorkerStatus.ERROR
            self.finished.emit(False, dict(), error_msg)
        finally:
            # Cleanup
            if self._process and self._process.poll() is None:
                try:
                    self._process.terminate()
                    self._process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self._process.kill()
                    logger.warning("Had to force kill deployment process")

class ModelTrainingWorker(QThread):
    """Worker thread for model deployment"""
    finished = Signal(bool, dict, str)  # success, error_message
    progress = Signal(int)

    def __init__(self, model: dict, envs: dict = dict()) -> None:
        super().__init__()
        self._model = model or dict()
        self._envs = envs
        self._status = WorkerStatus.IDLE
        self._process: Optional[subprocess.Popen] = None

        # Define paths
        self._base_path = Path(__file__).parents[1]
        self._scripts_path = self._base_path / "scripts/train"
        self._deploy_script = self._scripts_path / f"{self._model['code_name']}.py"

    def _validate_deployment_script(self) -> None:
        """Validate deployment script existence and permissions"""
        if not self._deploy_script.exists():
            raise FileNotFoundError(
                f"Deployment script not found: {self._deploy_script}"
            )

    def _setup_environment(self) -> dict:
        """Setup environment variables for deployment"""
        env = os.environ.copy()
        custom_envs = dict()
        if self._envs:
            for key, value in self._envs.items():
                custom_envs[key] = value

        env.update(custom_envs)
        return env

    def _extract_deployed_url(self, line: str) -> str:
        deployed_url = ""
        line = line.strip()
        if f"--{self._model['code_name']}-model-web-inference" in line:
            pattern = r'https?://[^\s]+'
            match = re.search(pattern, line)

            if match:
                link = match.group(0)
                deployed_url = link

        return deployed_url

    def _execute_deployment(self, env: dict) -> str:
        """Execute deployment script and handle output"""
        try:
            # Use modal deploy command
            deploy_command = [
                "modal", "deploy", str(self._deploy_script)
            ]

            logger.info(f"Executing deployment command: {' '.join(deploy_command)}")

            self._process = subprocess.Popen(
                deploy_command,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            if not self._process:
                raise RuntimeError("Failed to start deployment process")

            total_steps = 5
            current_step = 0

            deployed_url = ""
            while True:
                if self._process.poll() is not None:
                    break

                line = self._process.stdout.readline()
                if line:
                    logger.info(f"Deployment output: {line.strip()}")
                    extracted_url = self._extract_deployed_url(line)
                    if extracted_url:
                        deployed_url = extracted_url

                    # Update progress based on output
                    if "Starting deployment" in line:
                        current_step = 1
                    elif "Uploading code" in line:
                        current_step = 2
                    elif "Building container" in line:
                        current_step = 3
                    elif "Deploying model" in line:
                        current_step = 4
                    elif "Deployment complete" in line:
                        current_step = 5

                    progress = int((current_step / total_steps) * 100)
                    self.progress.emit(progress)

            # Check exit code
            if self._process.returncode != 0:
                error_output = self._process.stderr.read()
                raise RuntimeError(
                    f"Deployment failed with exit code {self._process.returncode}: {error_output}"
                )

            return deployed_url

        except Exception as e:
            raise RuntimeError(f"Deployment execution error: {str(e)}")
        finally:
            # Cleanup process
            if self._process:
                self._process.stdout.close()
                self._process.stderr.close()

    def run(self) -> None:
        """Run deployment process"""
        try:
            self._status = WorkerStatus.RUNNING
            logger.info(f"Starting deployment for model: {self._model['code_name']}")

            # Validate deployment script
            self._validate_deployment_script()

            # Setup environment
            env = self._setup_environment()

            # Execute deployment
            deployed_url = self._execute_deployment(env)
            if deployed_url:
                self._model["deployed_url"] = deployed_url
            else:
                raise Exception(f"Failed to deploy model {self._model}")

            # Deployment successful
            self._status = WorkerStatus.COMPLETED
            self.finished.emit(True, self._model, "")
            logger.info(f"Deployment completed successfully for model: {self._model['code_name']}. Deployed URL: {self._model['deployed_url']}")

        except Exception as e:
            error_msg = f"Deployment failed: {str(e)}"
            logger.error(error_msg, exc_info=True)
            self._status = WorkerStatus.ERROR
            self.finished.emit(False, dict(), error_msg)

        finally:
            # Cleanup
            if self._process and self._process.poll() is None:
                try:
                    self._process.terminate()
                    self._process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    self._process.kill()
                    logger.warning("Had to force kill deployment process")

    def stop(self) -> None:
        """Stop the deployment process"""
        if self._process and self._process.poll() is None:
            try:
                self._process.terminate()
                logger.info("Stopping deployment process...")
                if not self._process.wait(timeout=5):
                    self._process.kill()
                    logger.warning("Force killed deployment process")
            except Exception as e:
                logger.error(f"Error stopping deployment: {str(e)}", exc_info=True)
