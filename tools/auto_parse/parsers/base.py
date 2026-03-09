"""Base types for auto_parse plugin parsers."""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from datetime import datetime
from enum import IntEnum
from pathlib import Path
from typing import Protocol, runtime_checkable


class Severity(IntEnum):
    """Log severity levels, ordered for filtering."""
    DEBUG = 0
    INFO = 1
    WARN = 2
    ERROR = 3
    FATAL = 4


@dataclass(slots=True)
class ParsedEntry:
    """A single parsed log entry -- the universal data unit."""
    timestamp: str                    # HH:MM:SS
    source: str                       # Parser name ("Server", "DBError", etc.)
    category: str                     # Sub-category ("Transmog", "creature (faction)")
    severity: Severity                # Severity level
    text: str                         # Line text (may be truncated)
    line_number: int = 0              # Approximate line in source file
    metadata: dict = field(default_factory=dict)


# -- Timestamp extraction ------------------------------------------------------

_TS_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})[_T ](\d{2}:\d{2}:\d{2})")


def extract_ts(line: str) -> str | None:
    """Extract HH:MM:SS from a log line, or None."""
    m = _TS_RE.match(line)
    return m.group(2) if m else datetime.now().strftime("%H:%M:%S")


# -- Parser protocols ----------------------------------------------------------

@runtime_checkable
class LineParser(Protocol):
    """Parser that processes new lines from a tailed log file."""
    name: str
    log_file: str  # Filename relative to runtime_dir (e.g., "Server.log")

    def parse_lines(self, lines: list[str], line_offset: int = 0) -> list[ParsedEntry]:
        """Parse new log lines and return structured entries."""
        ...


@runtime_checkable
class ScanParser(Protocol):
    """Parser that scans a resource (not line-based)."""
    name: str

    def scan(self) -> list[ParsedEntry]:
        """Scan the resource and return entries."""
        ...

    def should_rescan(self) -> bool:
        """Return True if the resource has changed since last scan."""
        ...
