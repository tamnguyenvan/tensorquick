import yaml
from PySide6.QtCore import (
    QObject,
    Slot,
    Signal,
    Property,
)
from tensorquick.config import (
    default_settings, default_settings_path,
    session_settings, session_settings_path
)
from tensorquick.utils.general import find_index
from tensorquick.utils.shortcut import create_shortcut
from tensorquick import __version__

class DefaultSettings(QObject):
    versionChanged = Signal(str)
    availableModelsChanged = Signal(list)

    def __init__(self):
        super().__init__()
        self._default_settings = default_settings

    @Property(str, notify=versionChanged)
    def version(self):
        return __version__

    @Slot()
    def save(self):
        with open(default_settings_path, "wt") as f:
            yaml.dump(self._default_settings, f)

    @Slot()
    def load(self):
        available_models = self._default_settings.get("models", [])
        self.availableModelsChanged.emit(available_models)

class SessionSettings(QObject):
    # Appearance
    themeChanged = Signal(str)

    # Model related
    currentModelChanged = Signal(dict)
    deployedModelsChanged = Signal(list)
    availableModelsChanged = Signal(list)

    def __init__(self):
        super().__init__()
        self._session_settings = session_settings
        self._current_model = None

    @Property(str, notify=themeChanged)
    def currentTheme(self):
        return self._session_settings.get("theme", "dark")

    @currentTheme.setter
    def currentTheme(self, theme):
        self._session_settings["theme"] = theme
        self.themeChanged.emit(theme)

    @Property(dict, notify=currentModelChanged)
    def currentModel(self):
        return self._current_model

    @currentModel.setter
    def currentModel(self, model):
        if model and self._current_model != model:
            self._current_model = model
            code_names = [m["code_name"] for m in self._session_settings["deployed_models"]]
            index = max(0, find_index(code_names, model["code_name"]))
            self._session_settings["current_model"] = index
        self.currentModelChanged.emit(model)

    @Property(list, notify=deployedModelsChanged)
    def deployedModels(self):
        return self._session_settings.get("deployed_models", [])

    @deployedModels.setter
    def deployedModels(self, models):
        self._session_settings["deployed_models"] = models
        self.deployedModelsChanged.emit(models)

    @Slot()
    def load(self):
        available_models = self._session_settings.get("available_models", [])
        self.availableModelsChanged.emit(available_models)

        deployed_models = self._session_settings.get("deployed_models", [])
        self.deployedModelsChanged.emit(deployed_models)

        current_model_index = self._session_settings.get("current_model")
        active_model = None
        if current_model_index and current_model_index < len(deployed_models):
            active_model = deployed_models[current_model_index]
        else:
            # set current model
            for model in deployed_models:
                if model.get("active"):
                    active_model = model
                    break

            if not active_model and len(deployed_models) > 0:
                active_model = deployed_models[0]
        self.currentModel = active_model

    @Slot()
    def save(self):
        with open(session_settings_path, "wt") as f:
            yaml.dump(self._session_settings, f)

    @Slot()
    def createShortcut(self):
        """Create a shortcut"""
        create_shortcut()