"""
User idle detection: Win32 GetLastInputInfo + time-of-day window.
Determines when the daemon is allowed to perform mutating actions.
"""

import ctypes
import ctypes.wintypes
import logging
from datetime import datetime

log = logging.getLogger("daemon.idle")


class LASTINPUTINFO(ctypes.Structure):
    _fields_ = [
        ("cbSize", ctypes.wintypes.UINT),
        ("dwTime", ctypes.wintypes.DWORD),
    ]


def get_idle_seconds() -> float:
    """Get the number of seconds since the last keyboard/mouse input."""
    lii = LASTINPUTINFO()
    lii.cbSize = ctypes.sizeof(LASTINPUTINFO)
    if not ctypes.windll.user32.GetLastInputInfo(ctypes.byref(lii)):
        log.warning("GetLastInputInfo failed, assuming user is active")
        return 0.0

    tick_count = ctypes.windll.kernel32.GetTickCount64()
    idle_ms = tick_count - lii.dwTime
    return idle_ms / 1000.0


class IdleDetector:
    """Determines if the daemon is allowed to perform autonomous actions."""

    def __init__(self, idle_threshold_minutes: int = 20,
                 night_start_hour: int = 23, night_end_hour: int = 7,
                 force_autonomous: bool = False):
        self.idle_threshold_sec = idle_threshold_minutes * 60
        self.night_start = night_start_hour
        self.night_end = night_end_hour
        self.force = force_autonomous

    def is_user_away(self) -> bool:
        """
        Returns True if the daemon is allowed to perform mutating actions.

        User is considered "away" when ANY of:
        1. force_autonomous is True
        2. Idle for >= threshold minutes
        3. Current time is within the night window
        """
        if self.force:
            return True

        # Check idle time
        idle = get_idle_seconds()
        if idle >= self.idle_threshold_sec:
            log.debug("User idle for %.0f seconds (threshold: %d)",
                      idle, self.idle_threshold_sec)
            return True

        # Check night window
        hour = datetime.now().hour
        if self.night_start > self.night_end:
            # Window crosses midnight (e.g., 23-7)
            in_window = hour >= self.night_start or hour < self.night_end
        else:
            in_window = self.night_start <= hour < self.night_end

        if in_window:
            log.debug("Within night window (%02d:00-%02d:00), hour=%d",
                      self.night_start, self.night_end, hour)
            return True

        return False

    def get_status(self) -> dict:
        """Return current idle detection status for diagnostics."""
        idle = get_idle_seconds()
        hour = datetime.now().hour
        return {
            "idle_seconds": round(idle, 1),
            "idle_threshold_seconds": self.idle_threshold_sec,
            "idle_above_threshold": idle >= self.idle_threshold_sec,
            "current_hour": hour,
            "night_window": f"{self.night_start:02d}:00-{self.night_end:02d}:00",
            "in_night_window": self.is_user_away() and not (idle >= self.idle_threshold_sec),
            "force_autonomous": self.force,
            "user_away": self.is_user_away(),
        }
