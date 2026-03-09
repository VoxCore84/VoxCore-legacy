"""System tray icon -- green/yellow/red status, click to open PacketLog."""

from __future__ import annotations

import os
import threading
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .engine import SessionState

_COLORS = {
    "idle": (59, 185, 80),      # green
    "active": (210, 153, 34),   # yellow
    "error": (248, 81, 73),     # red
}


def _make_icon(color: tuple[int, int, int]):
    """Create a simple 64x64 circle icon."""
    from PIL import Image, ImageDraw

    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([8, 8, 56, 56], fill=color + (255,))
    return img


class TrayIcon:
    """System tray icon with status updates."""

    def __init__(self, output_dir: Path) -> None:
        self._output_dir = output_dir
        self._icon = None
        self._thread: threading.Thread | None = None
        self._status = "idle"

    def start(self) -> None:
        """Start the tray icon in a background thread."""
        try:
            import pystray
        except ImportError:
            return

        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def update_status(self, status: str) -> None:
        """Update icon color: 'idle', 'active', 'error'."""
        if self._icon is None:
            return
        if status != self._status:
            self._status = status
            self._icon.icon = _make_icon(_COLORS.get(status, _COLORS["idle"]))

    def update_tooltip(self, text: str) -> None:
        if self._icon:
            self._icon.title = text

    def stop(self) -> None:
        if self._icon:
            self._icon.stop()

    def _run(self) -> None:
        import pystray

        icon = pystray.Icon(
            "auto_parse",
            icon=_make_icon(_COLORS["idle"]),
            title="VoxCore Auto-Parse",
            menu=pystray.Menu(
                pystray.MenuItem("Open PacketLog", self._open_folder),
                pystray.MenuItem("Quit", self._quit),
            ),
        )
        self._icon = icon
        icon.run()

    def _open_folder(self, icon=None, item=None) -> None:
        os.startfile(str(self._output_dir))

    def _quit(self, icon=None, item=None) -> None:
        if self._icon:
            self._icon.stop()
