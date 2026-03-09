"""Server.log parser -- errors, warnings, fatals with context."""

from __future__ import annotations

import re
from collections import deque
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity, extract_ts

if TYPE_CHECKING:
    from ..config import Config

_ERROR_RE = re.compile(
    r"\b(FATAL|CRASH|EXCEPTION|ASSERT|Segfault|Access violation)\b", re.IGNORECASE
)
_SOFT_ERROR_RE = re.compile(r"\bERROR\b", re.IGNORECASE)
_WARN_RE = re.compile(r"\bWARN(?:ING)?\b", re.IGNORECASE)


class ServerLogParser:
    name = "Server"
    log_file = "Server.log"

    def __init__(self, config: Config) -> None:
        self._verbose = config.output.verbose

    def parse_lines(
        self, lines: list[str], line_offset: int = 0
    ) -> list[ParsedEntry]:
        entries: list[ParsedEntry] = []
        ctx: deque[str] = deque(maxlen=4)

        for i, line in enumerate(lines):
            lineno = line_offset + i + 1
            stripped = line.rstrip("\n\r")
            ctx.append(stripped)
            ts = extract_ts(stripped) or ""

            if _ERROR_RE.search(stripped):
                sev = Severity.FATAL
            elif _SOFT_ERROR_RE.search(stripped):
                sev = Severity.ERROR
            elif _WARN_RE.search(stripped):
                sev = Severity.WARN
            else:
                continue  # Skip INFO/DEBUG lines -- too noisy

            meta: dict = {}
            if self._verbose and sev >= Severity.ERROR:
                meta["context"] = list(ctx)

            entries.append(
                ParsedEntry(
                    timestamp=ts,
                    source=self.name,
                    category="fatal" if sev == Severity.FATAL else sev.name.lower(),
                    severity=sev,
                    text=stripped[:300],
                    line_number=lineno,
                    metadata=meta,
                )
            )

        return entries


def create(config: Config) -> ServerLogParser:
    return ServerLogParser(config)
