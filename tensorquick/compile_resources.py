import os
import subprocess
from pathlib import Path

import yaml
from loguru import logger

from tensorquick.config import session_settings, session_settings_path

def compile():
    # Commands to run
    current_dir = Path(__file__).parent
    resource_py = str(current_dir / "rc_image.py")
    resource_path = str(current_dir / "image.qrc")
    command = f"pyside6-rcc -o {resource_py} {resource_path}",
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        logger.info(f"Error executing command: {command}")
        logger.info(f"Error details: {e}")

def maybe_compile():
    compiled = session_settings.get("compiled", False)
    if not compiled:
        compile()
        logger.info(f"Compiled successfully")

        session_settings["compiled"] = True
        with open(session_settings_path, "wt") as f:
            yaml.dump(session_settings, f)

        logger.info(f"Saved compiled variable")
    else:
        logger.info(f"Resources compiled")