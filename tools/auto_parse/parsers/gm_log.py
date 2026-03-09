"""GM.log parser -- command extraction with player attribution."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity

if TYPE_CHECKING:
    from ..config import Config

_CMD_RE = re.compile(
    r"^(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}:\d{2})\s+Command:\s+(.+?)\s*\[Player:\s+(\S+)"
)
_CMD_NOPLAYER_RE = re.compile(
    r"^(\d{4}-\d{2}-\d{2}_\d{2}:\d{2}:\d{2})\s+Command:\s+(.+)"
)


class GMLogParser:
    name = "GM"
    log_file = "GM.log"

    def __init__(self, config: Config) -> None:
        pass

    def parse_lines(
        self, lines: list[str], line_offset: int = 0
    ) -> list[ParsedEntry]:
        entries: list[ParsedEntry] = []

        for i, line in enumerate(lines):
            m = _CMD_RE.match(line)
            if m:
                ts_raw, cmd, player = m.group(1), m.group(2).strip(), m.group(3)
            else:
                m2 = _CMD_NOPLAYER_RE.match(line)
                if m2:
                    ts_raw, cmd, player = m2.group(1), m2.group(2).strip(), "?"
                else:
                    continue

            ts = ts_raw.split("_")[1] if "_" in ts_raw else ts_raw
            lineno = line_offset + i + 1
            verb = cmd.split()[0] if cmd else "?"

            entries.append(
                ParsedEntry(
                    timestamp=ts,
                    source=self.name,
                    category=verb,
                    severity=Severity.INFO,
                    text=f"{cmd} -- {player}",
                    line_number=lineno,
                    metadata={"command": cmd, "player": player, "verb": verb},
                )
            )

        return entries


def create(config: Config) -> GMLogParser:
    return GMLogParser(config)
