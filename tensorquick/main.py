import sys
from pathlib import Path

from loguru import logger
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QGuiApplication, QIcon

from tensorquick.backend.pipeline import InferencePipeline
from tensorquick.backend.builder import ModelBuilder
from tensorquick.backend.settings import DefaultSettings, SessionSettings
from tensorquick.backend.clipboard import ClipboardModel
from tensorquick.compile_resources import maybe_compile

maybe_compile()

from tensorquick import rc_image

def init_application() -> tuple[QGuiApplication, QQmlApplicationEngine]:
    """Initialize Qt application and QML engine"""

    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    return app, engine

def main() -> int:
    """Application entry point"""
    try:
        app, engine = init_application()
        app_icon_path = str(Path(__file__).parent / "resources/icons/app-icon.ico")
        app.setWindowIcon(QIcon(app_icon_path))

        # Create and expose the backends to QML
        inference_pipeline = InferencePipeline()
        model_builder = ModelBuilder()
        default_settings = DefaultSettings()
        session_settings = SessionSettings()
        clipboard = ClipboardModel()

        engine.rootContext().setContextProperty("inferencePipeline", inference_pipeline)
        engine.rootContext().setContextProperty("modelBuilder", model_builder)
        engine.rootContext().setContextProperty("defaultSettings", default_settings)
        engine.rootContext().setContextProperty("sessionSettings", session_settings)
        engine.rootContext().setContextProperty("clipboard", clipboard)

        # Load the main QML file
        qml_file = Path(__file__).parent / "ui/Main.qml"
        engine.load(qml_file)

        if not engine.rootObjects():
            logger.error("Failed to load QML")
            return -1

        return app.exec()

    except Exception as e:
        logger.critical(f"Application error: {str(e)}", exc_info=True)
        return -1

if __name__ == "__main__":
    sys.exit(main())
