from dataclasses import dataclass
from typing import Optional
from enum import Enum, auto

@dataclass
class ModelCard:
    name: str = ""
    code_name: str = ""
    description: str = ""
    deployed_url: str = ""
    preview: str = ""
    active: bool = False


class WorkerStatus(Enum):
    """Status enum for worker threads"""
    IDLE = auto()
    RUNNING = auto()
    COMPLETED = auto()
    ERROR = auto()


@dataclass
class GenerationResult:
    """Data class for generation results"""
    success: bool
    image_path: Optional[str] = None
    error_message: Optional[str] = None
