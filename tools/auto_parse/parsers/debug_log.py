"""Debug.log parser -- categorized by subsystem (Transmog, RP, Companion, etc.)."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity, extract_ts

if TYPE_CHECKING:
    from ..config import Config

_KW_RE = re.compile(
    r"(transmog|Transmog|TRANSMOG|ViewedOutfit|TransmogOutfit"
    r"|CreatureOutfit|CustomNPC|customnpc"
    r"|RolePlay|Roleplay|roleplay"
    r"|Companion|companion"
    r"|VoxPlacer|voxplacer"
    r"|CMSG_|SMSG_"
    r"|ERROR|FATAL|CRASH"
    r"|spell_script|SpellScript)"
)


def _classify(keyword: str) -> tuple[str, Severity]:
    kw = keyword.lower()
    if "creatureoutfit" in kw or "customnpc" in kw or "roleplay" in kw:
        return "RolePlay/NPC", Severity.INFO
    if "transmog" in kw or "outfit" in kw or "viewedoutfit" in kw:
        return "Transmog", Severity.INFO
    if "companion" in kw:
        return "Companion", Severity.INFO
    if "voxplacer" in kw:
        return "VoxPlacer", Severity.INFO
    if "cmsg_" in kw or "smsg_" in kw:
        return "Packets", Severity.DEBUG
    if "error" in kw or "fatal" in kw or "crash" in kw:
        return "Errors", Severity.ERROR
    return "Other", Severity.INFO


class DebugLogParser:
    name = "Debug"
    log_file = "Debug.log"

    def __init__(self, config: Config) -> None:
        pass

    def parse_lines(
        self, lines: list[str], line_offset: int = 0
    ) -> list[ParsedEntry]:
        entries: list[ParsedEntry] = []

        for i, line in enumerate(lines):
            stripped = line.rstrip("\n\r")
            m = _KW_RE.search(stripped)
            if not m:
                continue

            lineno = line_offset + i + 1
            ts = extract_ts(stripped) or ""
            category, severity = _classify(m.group())

            entries.append(
                ParsedEntry(
                    timestamp=ts,
                    source=self.name,
                    category=category,
                    severity=severity,
                    text=stripped[:300],
                    line_number=lineno,
                )
            )

        return entries


def create(config: Config) -> DebugLogParser:
    return DebugLogParser(config)
