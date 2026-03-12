"""
Notification system: Discord webhooks + BurntToast (Windows toast notifications).
All daemon notifications go through this module.
"""

import json
import logging
import subprocess
from datetime import datetime
from enum import Enum

import requests

log = logging.getLogger("daemon.notify")


class Severity(Enum):
    SUCCESS = "success"
    WARNING = "warning"
    FAILURE = "failure"
    ACTION_REQUIRED = "action_required"
    INFO = "info"


# Discord embed colors
SEVERITY_COLORS = {
    Severity.SUCCESS: 0x2ECC71,        # green
    Severity.WARNING: 0xF1C40F,        # yellow
    Severity.FAILURE: 0xE74C3C,        # red
    Severity.ACTION_REQUIRED: 0xE67E22, # orange
    Severity.INFO: 0x3498DB,            # blue
}

SEVERITY_EMOJI = {
    Severity.SUCCESS: "OK",
    Severity.WARNING: "WARN",
    Severity.FAILURE: "FAIL",
    Severity.ACTION_REQUIRED: "ACTION",
    Severity.INFO: "INFO",
}


class Notifier:
    """Send notifications via Discord webhook and/or BurntToast."""

    def __init__(self, discord_webhook_url: str | None = None,
                 burnttoast_enabled: bool = True):
        self.discord_url = discord_webhook_url
        self.burnttoast = burnttoast_enabled
        self._discord_available = bool(discord_webhook_url)

    def send(self, title: str, message: str, severity: Severity = Severity.INFO,
             fields: dict | None = None):
        """Send a notification through all configured channels."""
        log.info("[%s] %s: %s", severity.value, title, message[:200])

        if self._discord_available:
            self._send_discord(title, message, severity, fields)

        if self.burnttoast:
            self._send_toast(title, message, severity)

    def _send_discord(self, title: str, message: str, severity: Severity,
                      fields: dict | None = None):
        """Send a Discord webhook embed."""
        embed = {
            "title": f"[{SEVERITY_EMOJI[severity]}] {title}",
            "description": message[:4000],  # Discord limit
            "color": SEVERITY_COLORS[severity],
            "timestamp": datetime.utcnow().isoformat(),
            "footer": {"text": "VoxCore Daemon"},
        }

        if fields:
            embed["fields"] = [
                {"name": k, "value": str(v)[:1024], "inline": True}
                for k, v in fields.items()
            ]

        payload = {"embeds": [embed]}

        try:
            resp = requests.post(
                self.discord_url,
                json=payload,
                timeout=10,
            )
            if resp.status_code not in (200, 204):
                log.warning("Discord webhook returned %d: %s",
                            resp.status_code, resp.text[:200])
        except Exception as e:
            log.error("Discord webhook failed: %s", e)

    def _send_toast(self, title: str, message: str, severity: Severity):
        """Send a Windows BurntToast notification via PowerShell."""
        # Truncate for toast readability
        short_msg = message[:200]
        tag = SEVERITY_EMOJI[severity]

        ps_cmd = (
            f'Import-Module BurntToast; '
            f'New-BurntToastNotification '
            f'-Text "[{tag}] {_ps_escape(title)}", "{_ps_escape(short_msg)}" '
            f'-AppLogo "" -UniqueIdentifier "voxcore-daemon"'
        )

        try:
            subprocess.run(
                ["powershell", "-NoProfile", "-Command", ps_cmd],
                capture_output=True, timeout=5,
            )
        except Exception as e:
            # Toast failures are non-critical
            log.debug("BurntToast failed (non-critical): %s", e)

    # Convenience methods
    def success(self, title: str, message: str, **fields):
        self.send(title, message, Severity.SUCCESS, fields or None)

    def warning(self, title: str, message: str, **fields):
        self.send(title, message, Severity.WARNING, fields or None)

    def failure(self, title: str, message: str, **fields):
        self.send(title, message, Severity.FAILURE, fields or None)

    def action_required(self, title: str, message: str, **fields):
        self.send(title, message, Severity.ACTION_REQUIRED, fields or None)

    def info(self, title: str, message: str, **fields):
        self.send(title, message, Severity.INFO, fields or None)


def _ps_escape(s: str) -> str:
    """Escape a string for PowerShell single-quoted context."""
    return s.replace("'", "''").replace('"', '`"').replace("\n", " ")
