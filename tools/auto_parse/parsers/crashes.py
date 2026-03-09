"""Crash dump detector -- scans Crashes/ for new .txt stack traces."""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING

from .base import ParsedEntry, Severity

if TYPE_CHECKING:
    from ..config import Config

# Filename pattern: <commit>_worldserver.exe_[YYYY_M_D_H_M_S].txt
_CRASH_RE = re.compile(
    r"^([a-f0-9]+\+?)_worldserver\.exe_\[(\d{4})_(\d+)_(\d+)_(\d+)_(\d+)_(\d+)\]\.txt$"
)

_EXCEPTION_RE = re.compile(r"Exception code:\s*([A-F0-9]+)\s+(\S+)")
_FAULT_RE = re.compile(r"Fault address:\s*(\S+)")
_STACK_FUNC_RE = re.compile(r"(\S+\.cpp)\s+line\s+(\d+)")


class CrashScanner:
    name = "Crash"

    def __init__(self, config: Config) -> None:
        self._crashes_dir = config.paths.crashes_dir
        self._seen_files: set[str] = set()

    def should_rescan(self) -> bool:
        if not self._crashes_dir.exists():
            return False
        current = {f.name for f in self._crashes_dir.glob("*.txt")}
        return current != self._seen_files

    def scan(self) -> list[ParsedEntry]:
        if not self._crashes_dir.exists():
            return []

        entries: list[ParsedEntry] = []
        current_files = sorted(self._crashes_dir.glob("*.txt"))

        for path in current_files:
            if path.name in self._seen_files:
                continue

            m = _CRASH_RE.match(path.name)
            if not m:
                continue

            commit = m.group(1)
            year, month, day = int(m.group(2)), int(m.group(3)), int(m.group(4))
            hour, minute, sec = int(m.group(5)), int(m.group(6)), int(m.group(7))
            ts = f"{hour:02d}:{minute:02d}:{sec:02d}"

            # Parse the crash text for key info
            exception_code = ""
            fault_addr = ""
            first_source_frame = ""
            try:
                text = path.read_text(encoding="utf-8", errors="replace")
                em = _EXCEPTION_RE.search(text)
                if em:
                    exception_code = f"{em.group(1)} {em.group(2)}"
                fm = _FAULT_RE.search(text)
                if fm:
                    fault_addr = fm.group(1)
                sm = _STACK_FUNC_RE.search(text)
                if sm:
                    first_source_frame = f"{sm.group(1)}:{sm.group(2)}"
            except OSError:
                pass

            dmp_path = path.with_suffix(".dmp")
            dmp_size = dmp_path.stat().st_size if dmp_path.exists() else 0

            summary = f"CRASH [{exception_code}]"
            if first_source_frame:
                summary += f" at {first_source_frame}"
            summary += f" (commit {commit})"

            entries.append(
                ParsedEntry(
                    timestamp=ts,
                    source=self.name,
                    category="crash_dump",
                    severity=Severity.FATAL,
                    text=summary,
                    metadata={
                        "commit": commit,
                        "exception": exception_code,
                        "fault_addr": fault_addr,
                        "first_frame": first_source_frame,
                        "dmp_size": dmp_size,
                        "txt_file": path.name,
                        "date": f"{year}-{month:02d}-{day:02d}",
                    },
                )
            )

            # Only mark as seen if we found a fault address or a stack frame (indicating the write finished)
            if fault_addr or first_source_frame:
                self._seen_files.add(path.name)

        return entries


def create(config: Config) -> CrashScanner:
    return CrashScanner(config)
