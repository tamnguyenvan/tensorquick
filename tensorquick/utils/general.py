from typing import Tuple
from pathlib import Path

def validate_image_path(image_path: str) -> Tuple[bool, str]:
    """
    Validates if the image path exists and is accessible

    Args:
        image_path: Path to the image file

    Returns:
        Tuple of (is_valid, error_message)
    """
    if not image_path:
        return False, "No image path provided"

    if not Path(image_path).exists():
        return False, "Image file does not exist"

    return True, ""

def find_index(a, element):
    try:
        return a.index(element)
    except ValueError:
        return -1