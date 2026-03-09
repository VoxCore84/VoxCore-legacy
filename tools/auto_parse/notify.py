"""Windows toast notifications via winotify."""

from __future__ import annotations


def send_toast(title: str, message: str, icon_path: str = "") -> None:
    """Send a Windows toast notification. Best-effort -- never raises."""
    try:
        from winotify import Notification

        toast = Notification(
            app_id="VoxCore Auto-Parse",
            title=title,
            msg=message[:256],
        )
        if icon_path:
            toast.set_audio(None, suppress=True)
        toast.show()
    except Exception:
        pass  # Notifications are non-critical
