import os
import sys
import platform
from pathlib import Path
import subprocess
import stat

# Global configuration
APP_CONFIG = {
    # App identity
    'DISPLAY_NAME': 'Tensor Quick',  # Display name shown to users
    'APP_NAME': 'tensorquick',      # Technical name for files and commands
    'MODULE_NAME': 'tensorquick.main',  # Python module to run
    'GENERIC_NAME': 'Tensor Quick Application',  # Generic name for Linux .desktop
    'COMMENT': 'PySide6 Tensor Quick Application',  # Description for Linux .desktop

    # Paths and resources
    'ICON_PATH': str(Path(__file__).parents[1] / "resources" / "icons" / "app-icon.png"),

    # Categories and window properties
    'CATEGORIES': 'Utility;Development;',
    'WM_CLASS': 'Tensor Quick',  # Window manager class for Linux
    # Version info
    'VERSION': '0.1.0'
}

def get_desktop_path():
    """Get the desktop path for current user across different OS."""
    if platform.system() == "Windows":
        import winreg
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders") as key:
            return winreg.QueryValueEx(key, "Desktop")[0]
    else:
        return str(Path.home() / "Desktop")

def create_windows_shortcut(desktop_path):
    """Create a Windows .lnk shortcut."""
    try:
        import win32com.client
        shell = win32com.client.Dispatch("WScript.Shell")
        shortcut_path = os.path.join(desktop_path, f"{APP_CONFIG['DISPLAY_NAME']}.lnk")
        shortcut = shell.CreateShortCut(shortcut_path)

        # Get Python executable path
        python_path = sys.executable.replace("python.exe", "pythonw.exe")

        shortcut.Targetpath = python_path
        shortcut.Arguments = f"-m {APP_CONFIG['MODULE_NAME']}"
        shortcut.IconLocation = APP_CONFIG['ICON_PATH'].replace("app-icon.png", "app-icon.ico")
        shortcut.WorkingDirectory = os.path.dirname(python_path)
        shortcut.save()
        print(f"Windows shortcut created at: {shortcut_path}")
        return True
    except Exception as e:
        print(f"Error creating Windows shortcut: {e}")
        return False

def create_linux_shortcut():
    """Create a Linux .desktop file in the applications directory."""
    try:
        # Create applications directory if it doesn't exist
        apps_dir = Path.home() / ".local" / "share" / "applications"
        apps_dir.mkdir(parents=True, exist_ok=True)

        desktop_file = apps_dir / f"{APP_CONFIG['APP_NAME']}.desktop"
        python_path = sys.executable

        # Get absolute path to the script's directory
        script_dir = os.path.dirname(os.path.abspath(__file__))

        desktop_entry = f"""[Desktop Entry]
Version={APP_CONFIG['VERSION']}
Type=Application
Name={APP_CONFIG['DISPLAY_NAME']}
GenericName={APP_CONFIG['GENERIC_NAME']}
Comment={APP_CONFIG['COMMENT']}
Exec={python_path} -m {APP_CONFIG['MODULE_NAME']}
Icon={APP_CONFIG['ICON_PATH']}
Terminal=false
Categories={APP_CONFIG['CATEGORIES']}
StartupNotify=true
StartupWMClass={APP_CONFIG['WM_CLASS']}
Path={script_dir}
"""

        with open(desktop_file, 'w') as f:
            f.write(desktop_entry)

        # Make the .desktop file executable
        os.chmod(desktop_file, 0o755)

        # Update desktop database
        try:
            subprocess.run(['update-desktop-database', str(apps_dir)], check=True)
        except (subprocess.SubprocessError, FileNotFoundError):
            print("Note: Could not update desktop database. The shortcut may take effect after restart.")

        print(f"Linux shortcut created at: {desktop_file}")
        return True
    except Exception as e:
        print(f"Error creating Linux shortcut: {e}")
        return False

def create_macos_app():
    """Create a proper macOS .app bundle instead of a .command file"""
    try:
        import os
        import sys
        from pathlib import Path

        # Create app bundle structure
        app_name = APP_CONFIG['DISPLAY_NAME']
        bundle_dir = Path(get_desktop_path()) / f"{app_name}.app"
        contents_dir = bundle_dir / "Contents"
        macos_dir = contents_dir / "MacOS"
        resources_dir = contents_dir / "Resources"

        # Create directories
        for dir_path in [contents_dir, macos_dir, resources_dir]:
            dir_path.mkdir(parents=True, exist_ok=True)

        # Create Info.plist
        info_plist = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>{app_name}</string>
    <key>CFBundleDisplayName</key>
    <string>{APP_CONFIG['DISPLAY_NAME']}</string>
    <key>CFBundleIdentifier</key>
    <string>com.{APP_CONFIG['APP_NAME']}</string>
    <key>CFBundleVersion</key>
    <string>{APP_CONFIG['VERSION']}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
</dict>
</plist>"""

        with open(contents_dir / "Info.plist", "w") as f:
            f.write(info_plist)

        # Create launcher script
        launcher_script = f"""#!/bin/bash
cd "$(dirname "$0")"
export PYTHONPATH="{os.path.dirname(os.path.dirname(APP_CONFIG['MODULE_NAME'].replace('.', '/')))}"
"{sys.executable}" -m {APP_CONFIG['MODULE_NAME']}
"""

        launcher_path = macos_dir / "launcher"
        with open(launcher_path, "w") as f:
            f.write(launcher_script)

        # Make launcher executable
        os.chmod(launcher_path, 0o755)

        # Copy icon if it exists
        if os.path.exists(APP_CONFIG['ICON_PATH']):
            import shutil
            icon_name = os.path.basename(APP_CONFIG['ICON_PATH'])
            shutil.copy2(APP_CONFIG['ICON_PATH'], resources_dir / icon_name)

        print(f"macOS app bundle created at: {bundle_dir}")
        return True

    except Exception as e:
        print(f"Error creating macOS app bundle: {e}")
        return False

def create_shortcut():
    """Create desktop shortcut based on the current operating system."""
    # Ensure icon exists
    if not os.path.exists(APP_CONFIG['ICON_PATH']):
        print(f"Warning: Icon file not found at {APP_CONFIG['ICON_PATH']}")

    # Create shortcut based on OS
    system = platform.system()
    if system == "Windows":
        try:
            import win32com.client
        except ImportError:
            print("Please install pywin32: pip install pywin32")
            return False
        return create_windows_shortcut(get_desktop_path())

    elif system == "Linux":
        return create_linux_shortcut()

    elif system == "Darwin":  # macOS
        return create_macos_shortcut(get_desktop_path())

    else:
        print(f"Unsupported operating system: {system}")
        return False

if __name__ == "__main__":
    if create_shortcut():
        print("Shortcut created successfully!")
    else:
        print("Failed to create shortcut.")