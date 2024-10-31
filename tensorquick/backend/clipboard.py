from loguru import logger

from PySide6.QtGui import QGuiApplication
from PySide6.QtCore import QObject, Slot

from tensorquick.utils.general import validate_image_path

class ClipboardModel(QObject):
    def __init__(self):
        super().__init__()
        self._clipboard = QGuiApplication.clipboard()

    @Slot(str)
    def copyImageToClipboard(self, image_path: str):
        try:
            is_valid, error = validate_image_path(image_path)
            if not is_valid:
                return False, error

            self._clipboard.setImage(image_path)
            logger.info("Image copied to clipboard")
            return True, ""

        except Exception as e:
            error_msg = f"Error copying to clipboard: {str(e)}"
            logger.error(error_msg, exc_info=True)
            return False, error_msg

    @Slot(str)
    def copyTextToClipboard(self, text: str):
        try:
            self._clipboard.setText(text)
            logger.info("Text copied to clipboard")
            return True, ""
        except Exception as e:
            error_msg = f"Error copying to clipboard: {str(e)}"
            logger.error(error_msg, exc_info=True)
            return False, error_msg