from pathlib import Path

from PySide6.QtQuick import QQuickImageProvider
from PySide6.QtGui import QImage

class ImageProvider(QQuickImageProvider):
    def __init__(self):
        super().__init__(QQuickImageProvider.Image)
        self._image_dir = Path(__file__).parents[1] / "resources/images"
        self._placeholder_path = self._image_dir / "model-preview-placeholder.png"

    def requestImage(self, id, size, requestedSize):
        # Create the full path for the requested image
        image_path = self._image_dir / id

        # Load the image
        if image_path.is_file():
            image = QImage(str(image_path))
        else:
            # Load the placeholder image if the requested image is not found
            image = QImage(str(self._placeholder_path))

        # Resize the image if a requested size is provided
        if requestedSize.width() > 0 and requestedSize.height() > 0:
            image = image.scaled(requestedSize.width(), requestedSize.height(), aspectRatioMode=QImage.KeepAspectRatio)

        return image
