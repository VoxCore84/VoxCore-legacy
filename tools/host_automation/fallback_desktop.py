import sys

class DesktopFallback:
    def __init__(self, config: dict):
        self.config = config
        self.app = None
        
        try:
            from pywinauto import Application, Desktop
            self.Application = Application
            self.Desktop = Desktop
            self.installed = True
        except ImportError:
            self.installed = False

    def require_installed(self):
        if not self.installed:
            raise RuntimeError("pywinauto is not installed. Run: pip install pywinauto")

    def focus_window_by_title(self, title_regex: str):
        self.require_installed()
        desktop = self.Desktop(backend="uia")
        
        try:
            window = desktop.window(title_re=title_regex)
            window.set_focus()
            return True
        except Exception as e:
            return False

    def connect_to_process(self, process_id: int):
        self.require_installed()
        try:
            self.app = self.Application(backend="uia").connect(process=process_id)
            return True
        except Exception:
            return False
