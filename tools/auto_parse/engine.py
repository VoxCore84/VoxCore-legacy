"""Core engine -- LogTailer, SessionState, poll loop, session lifecycle."""

from __future__ import annotations

import json
import logging
import subprocess
import time
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING

from .parsers.base import LineParser, ParsedEntry, ScanParser, Severity

if TYPE_CHECKING:
    from .config import Config

log = logging.getLogger("auto_parse")


# -- Incremental log tailer ----------------------------------------------------

class LogTailer:
    """Reads only new content from a growing log file (like tail -f)."""

    def __init__(self, path: Path):
        self.path = path
        self.offset = 0
        self.total_lines = 0

    def read_new(self) -> list[str]:
        """Return new lines since last call. Handles truncation/rotation."""
        if not self.path.exists():
            self.offset = 0
            return []

        try:
            size = self.path.stat().st_size
        except OSError:
            return []

        if size < self.offset:
            self.offset = 0  # File was truncated or rotated
            self.total_lines = 0

        if size == self.offset:
            return []

        lines: list[str] = []
        try:
            with open(self.path, "r", encoding="utf-8", errors="replace") as f:
                f.seek(self.offset)
                for raw in f:
                    lines.append(raw.rstrip("\n\r"))
                self.offset = f.tell()
        except OSError:
            pass

        self.total_lines += len(lines)
        return lines

    def read_all(self) -> list[str]:
        """Read entire file (for one-shot mode)."""
        self.offset = 0
        self.total_lines = 0
        return self.read_new()

    def reset(self) -> None:
        self.offset = 0
        self.total_lines = 0


# -- Server process detection --------------------------------------------------

def is_server_running() -> bool:
    """Check if worldserver.exe is currently running."""
    try:
        result = subprocess.run(
            ["tasklist", "/FI", "IMAGENAME eq worldserver.exe", "/NH"],
            capture_output=True, text=True, timeout=5,
        )
        return "worldserver.exe" in result.stdout
    except Exception:
        return False


# -- Session state -------------------------------------------------------------

@dataclass
class SessionState:
    """Accumulated parsing state for the current server session."""

    # All entries, grouped by source
    entries_by_source: dict[str, list[ParsedEntry]] = field(default_factory=lambda: defaultdict(list))

    # Flat lists for output
    all_entries: list[ParsedEntry] = field(default_factory=list)
    timeline_entries: list[ParsedEntry] = field(default_factory=list)
    alerts: list[ParsedEntry] = field(default_factory=list)

    # Counters
    line_counts: dict[str, int] = field(default_factory=lambda: Counter())

    # Session metadata
    session_start: datetime = field(default_factory=datetime.now)
    server_was_running: bool = False
    pkt_pipeline_ran: bool = False
    poll_count: int = 0
    last_poll_ms: float = 0.0

    # Sources excluded from timeline (too noisy -- have their own summary files)
    _TIMELINE_EXCLUDED: frozenset[str] = frozenset({"DBError"})

    def add_entries(self, entries: list[ParsedEntry]) -> None:
        """Add parsed entries to the session state."""
        for e in entries:
            self.all_entries.append(e)
            self.entries_by_source[e.source].append(e)
            if e.source not in self._TIMELINE_EXCLUDED:
                self.timeline_entries.append(e)
            if e.severity >= Severity.ERROR:
                self.alerts.append(e)

    def get_timeline(self, limit: int = 0) -> list[ParsedEntry]:
        """Return timeline entries sorted by timestamp, optionally limited."""
        sorted_entries = sorted(self.timeline_entries, key=lambda e: e.timestamp)
        if limit > 0:
            return sorted_entries[-limit:]
        return sorted_entries

    def get_entries(self, source: str) -> list[ParsedEntry]:
        return self.entries_by_source.get(source, [])

    def get_category_counts(self, source: str) -> Counter:
        """Count entries by category for a specific source."""
        c: Counter = Counter()
        for e in self.entries_by_source.get(source, []):
            c[e.category] += 1
        return c

    @property
    def uptime_seconds(self) -> float:
        return (datetime.now() - self.session_start).total_seconds()

    @property
    def uptime_str(self) -> str:
        s = int(self.uptime_seconds)
        h, m = divmod(s, 3600)
        m, sec = divmod(m, 60)
        if h:
            return f"{h}h {m}m"
        return f"{m}m {sec}s"

    def reset_for_new_session(self) -> None:
        """Clear all accumulated state for a fresh session."""
        self.entries_by_source.clear()
        self.all_entries.clear()
        self.timeline_entries.clear()
        self.alerts.clear()
        self.line_counts.clear()
        self.pkt_pipeline_ran = False
        self.poll_count = 0
        self.session_start = datetime.now()

    # -- Persistence -----------------------------------------------------------

    def save(self, path: Path) -> None:
        """Persist minimal state for crash recovery."""
        data = {
            "version": 1,
            "session_start": self.session_start.isoformat(),
            "poll_count": self.poll_count,
            "line_counts": dict(self.line_counts),
            "entry_count": len(self.all_entries),
            "alert_count": len(self.alerts),
            "pkt_pipeline_ran": self.pkt_pipeline_ran,
        }
        tmp = path.with_suffix(".tmp")
        try:
            tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
            tmp.replace(path)
        except OSError:
            pass  # Will attempt again on next cycle

    @classmethod
    def load(cls, path: Path) -> SessionState | None:
        """Load persisted state. Returns None if file missing or corrupt."""
        if not path.exists():
            return None
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            if data.get("version") != 1:
                return None
            state = cls()
            state.session_start = datetime.fromisoformat(data["session_start"])
            state.poll_count = data.get("poll_count", 0)
            state.line_counts = Counter(data.get("line_counts", {}))
            state.pkt_pipeline_ran = data.get("pkt_pipeline_ran", False)
            return state
        except Exception:
            return None
