"""Bnet.log parser -- auth failures, disconnections, build mismatches."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity, extract_ts

if TYPE_CHECKING:
    from ..config import Config

_PATTERNS: list[tuple[re.Pattern, str, Severity]] = [
    (re.compile(r"(LOGIN_FAILED|AUTH_FAILED|BAN_)", re.I), "auth_failure", Severity.ERROR),
    (re.compile(r"(disconnected|connection.*lost|socket.*closed)", re.I), "disconnect", Severity.WARN),
    (re.compile(r"(build.*mismatch|version.*mismatch|incompatible)", re.I), "build_mismatch", Severity.ERROR),
    (re.compile(r"\bERROR\b", re.I), "error", Severity.ERROR),
    (re.compile(r"\bWARN(?:ING)?\b", re.I), "warning", Severity.WARN),
]


class BnetLogParser:
    name = "Bnet"
    log_file = "Bnet.log"

    def __init__(self, config: Config) -> None:
        pass

    def parse_lines(
        self, lines: list[str], line_offset: int = 0
    ) -> list[ParsedEntry]:
        entries: list[ParsedEntry] = []

        for i, line in enumerate(lines):
            stripped = line.rstrip("\n\r")
            if not stripped:
                continue

            for regex, category, severity in _PATTERNS:
                if regex.search(stripped):
                    ts = extract_ts(stripped) or ""
                    entries.append(
                        ParsedEntry(
                            timestamp=ts,
                            source=self.name,
                            category=category,
                            severity=severity,
                            text=stripped[:300],
                            line_number=line_offset + i + 1,
                        )
                    )
                    break  # first match wins

        return entries


def create(config: Config) -> BnetLogParser:
    return BnetLogParser(config)
