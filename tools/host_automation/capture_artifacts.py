import os
import json
import time
from pathlib import Path
from datetime import datetime

class ArtifactCapture:
    def __init__(self, run_id: str, config: dict):
        self.run_id = run_id
        self.config = config
        self.base_dir = Path(config.get("artifacts_dir", "logs/host_automation"))
        
        self.run_dir = self.base_dir / "runs" / self.run_id
        self.screenshots_dir = self.run_dir / "screenshots"
        self.dumps_dir = self.run_dir / "page_dumps"
        
        os.makedirs(self.run_dir, exist_ok=True)
        os.makedirs(self.screenshots_dir, exist_ok=True)
        os.makedirs(self.dumps_dir, exist_ok=True)

        self.manifest = {
            "run_id": self.run_id,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "status": "in_progress",
            "actions": [],
            "error": None,
            "artifacts": {
                "screenshots": [],
                "page_dumps": []
            }
        }

    def record_action(self, action_type: str, details: dict):
        self.manifest["actions"].append({
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "type": action_type,
            "details": details
        })

    def capture_screenshot(self, page, name: str):
        filename = f"{name}_{int(time.time())}.png"
        filepath = self.screenshots_dir / filename
        page.screenshot(path=str(filepath), full_page=True)
        self.manifest["artifacts"]["screenshots"].append(str(filepath))
        return filepath

    def capture_html_dump(self, page, name: str):
        filename = f"{name}_{int(time.time())}.html"
        filepath = self.dumps_dir / filename
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(page.content())
        self.manifest["artifacts"]["page_dumps"].append(str(filepath))
        return filepath

    def write_manifest(self, status: str = "completed", error: str = None):
        self.manifest["status"] = status
        if error:
            self.manifest["error"] = error
            
        manifest_path = self.run_dir / "manifest.json"
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(self.manifest, f, indent=4)
            
        self._write_markdown_summary()
        
        # Maintain a symlink/copy of the latest run for easy access
        latest_manifest_path = self.base_dir / "latest_run_manifest.json"
        with open(latest_manifest_path, "w", encoding="utf-8") as f:
            json.dump(self.manifest, f, indent=4)

    def _write_markdown_summary(self):
        summary_path = self.run_dir / "summary.md"
        latest_summary = self.base_dir / "latest_run_summary.md"
        
        lines = [
            f"# Host Automation Run: {self.run_id}",
            f"**Status:** {self.manifest['status']}",
            f"**Time:** {self.manifest['timestamp']}",
            ""
        ]
        
        if self.manifest.get("error"):
            lines.extend([
                "## Error",
                f"```\n{self.manifest['error']}\n```",
                ""
            ])
            
        lines.append("## Actions")
        for i, action in enumerate(self.manifest["actions"], 1):
            detail_str = json.dumps(action['details'])
            lines.append(f"{i}. **{action['type']}** - `{detail_str}`")
            
        content = "\n".join(lines)
        
        with open(summary_path, "w", encoding="utf-8") as f:
            f.write(content)
            
        with open(latest_summary, "w", encoding="utf-8") as f:
            f.write(content)
