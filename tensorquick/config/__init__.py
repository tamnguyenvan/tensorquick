import os
from pathlib import Path

import yaml
from loguru import logger

def load_config(config_path):
    config = dict()
    if os.path.exists(config_path):
        try:
            with open(config_path, "r") as f:
                config = yaml.safe_load(f)
        except Exception as e:
            logger.error(f"Failed to load config: {str(e)}")

    return config


default_settings_path = os.getenv("BUNCHA_DEFAULT_CONFIG_PATH") or Path(__file__).parent / "default.yaml"
default_settings = load_config(default_settings_path)

session_settings_path = os.getenv("BUNCHA_CONFIG_PATH") or Path("~/.tensorquick.yaml").expanduser()
session_settings = load_config(session_settings_path)
