class BrowserActions:
    def __init__(self, page, artifacts):
        self.page = page
        self.artifacts = artifacts
        
    def open_url(self, url: str):
        self.artifacts.record_action("open_url", {"url": url})
        response = self.page.goto(url, wait_until="domcontentloaded")
        
        # Always take an initial screenshot after page load
        self.artifacts.capture_screenshot(self.page, "after_load")
        
        return {
            "status": response.status if response else None,
            "url": self.page.url,
            "title": self.page.title()
        }

    def inspect_page(self):
        self.artifacts.record_action("inspect_page", {"url": self.page.url})
        return {
            "url": self.page.url,
            "title": self.page.title(),
            "html_length": len(self.page.content())
        }
        
    def click(self, selector: str, wait_for_nav: bool = False, force: bool = False):
        self.artifacts.record_action("click", {"selector": selector, "force": force})
        if wait_for_nav:
            with self.page.expect_navigation():
                self.page.click(selector, force=force)
        else:
            self.page.click(selector, force=force)
            
        self.artifacts.capture_screenshot(self.page, "after_click")
        return True
        
    def fill(self, selector: str, text: str):
        # We don't log the actual text just in case it's a secret
        self.artifacts.record_action("fill", {"selector": selector, "length": len(text)})
        self.page.fill(selector, text)
        return True

    def extract_text(self, selector: str):
        self.artifacts.record_action("extract_text", {"selector": selector})
        try:
            element = self.page.locator(selector).first
            return element.inner_text()
        except Exception as e:
            return None
