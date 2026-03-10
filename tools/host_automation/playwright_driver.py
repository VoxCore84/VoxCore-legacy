import os
from pathlib import Path
from playwright.sync_api import sync_playwright, Playwright, Browser, BrowserContext

class PlaywrightDriver:
    def __init__(self, config: dict):
        self.config = config
        self.playwright: Playwright = None
        self.browser: Browser = None
        self.context: BrowserContext = None
        
    def start(self):
        self.playwright = sync_playwright().start()
        
        browser_type_name = self.config.get("browser_type", "chromium")
        headless = self.config.get("headless", False)
        
        browser_type = getattr(self.playwright, browser_type_name)
        
        # Determine if we should use a persistent context (better for avoiding re-login during automation flows)
        user_data_dir = self.config.get("user_data_dir")
        
        if user_data_dir:
            os.makedirs(user_data_dir, exist_ok=True)
            self.context = browser_type.launch_persistent_context(
                user_data_dir=user_data_dir,
                headless=headless,
                viewport=self.config.get("default_viewport", {"width": 1280, "height": 720}),
                record_video_dir=self.config.get("artifacts_dir") if self.config.get("capture_video") else None
            )
        else:
            self.browser = browser_type.launch(headless=headless)
            self.context = self.browser.new_context(
                viewport=self.config.get("default_viewport", {"width": 1280, "height": 720}),
                record_video_dir=self.config.get("artifacts_dir") if self.config.get("capture_video") else None
            )
            
        if self.config.get("capture_trace"):
            self.context.tracing.start(screenshots=True, snapshots=True, sources=True)
            
        return self.context
        
    def attach(self, cdp_url: str):
        """Attach Mode - Connect to an already running Chromium browser over CDP."""
        self.playwright = sync_playwright().start()
        browser_type = self.playwright.chromium
        self.browser = browser_type.connect_over_cdp(cdp_url)
        
        if self.browser.contexts:
            self.context = self.browser.contexts[0]
        else:
            self.context = self.browser.new_context()
            
        return self.context

    def stop(self, trace_name="trace.zip"):
        if self.context and self.config.get("capture_trace"):
            artifacts_dir = Path(self.config.get("artifacts_dir", "logs/host_automation"))
            trace_path = artifacts_dir / "traces" / trace_name
            os.makedirs(trace_path.parent, exist_ok=True)
            self.context.tracing.stop(path=str(trace_path))
            
        if self.context:
            self.context.close()
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
