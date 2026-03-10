import uuid
import traceback
from playwright_driver import PlaywrightDriver
from capture_artifacts import ArtifactCapture
from browser_actions import BrowserActions

class HostSession:
    def __init__(self, config: dict, mode: str = "managed"):
        self.config = config
        self.mode = mode
        self.run_id = f"run_{uuid.uuid4().hex[:8]}"
        
        self.driver = PlaywrightDriver(self.config)
        self.artifacts = ArtifactCapture(self.run_id, self.config)
        
        self.context = None
        self.page = None
        self.actions = None
        self.is_dry_run = (self.mode == "dry-run")
        
    def __enter__(self):
        try:
            if not self.is_dry_run:
                self.context = self.driver.start()
                self.page = self.context.new_page()
                # Expose the actions wrapper
                self.actions = BrowserActions(self.page, self.artifacts)
            else:
                self.artifacts.record_action("init", {"mode": "dry-run", "message": "Validating plan only."})
                
            return self
        except Exception as e:
            self._handle_failure(e)
            raise
            
    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is not None:
            self._handle_failure(exc_val)
        else:
            self.artifacts.write_manifest(status="completed")
            
        if not self.is_dry_run:
            self.driver.stop()
            
    def _handle_failure(self, exception: Exception):
        error_trace = "".join(traceback.format_exception(type(exception), exception, exception.__traceback__))
        
        if self.page and self.config.get("capture_html_on_failure"):
            try:
                self.artifacts.capture_html_dump(self.page, "failure_dump")
                self.artifacts.capture_screenshot(self.page, "failure_screenshot")
            except:
                pass
                
        self.artifacts.write_manifest(status="failed", error=error_trace)
