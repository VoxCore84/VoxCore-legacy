"""DBCache.bin scanner -- decode + cross-reference via external wago scripts."""

from __future__ import annotations

import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING

from ..writers import atomic_write
from .base import ParsedEntry, Severity

if TYPE_CHECKING:
    from ..config import Config


class DBCacheScanner:
    name = "DBCache"

    def __init__(self, config: Config) -> None:
        self._adb_dir = config.paths.adb_cache_dir
        self._wago_dir = config.paths.wago_dir
        self._output_dir = config.paths.output_dir
        self._dbcache = self._adb_dir / "DBCache.bin"
        self._decode_script = self._wago_dir / "decode_dbcache.py"
        self._xref_script = self._wago_dir / "xref_dbcache.py"
        self._last_mtime: float = 0.0

    def should_rescan(self) -> bool:
        if not self._dbcache.exists():
            return False
        try:
            mt = self._dbcache.stat().st_mtime
            if mt != self._last_mtime:
                return True
        except OSError:
            pass
        return False

    def scan(self) -> list[ParsedEntry]:
        if not self._dbcache.exists():
            return [
                ParsedEntry(
                    timestamp=datetime.now().strftime("%H:%M:%S"),
                    source=self.name,
                    category="missing",
                    severity=Severity.INFO,
                    text="DBCache.bin not found -- WoW client hasn't connected yet.",
                )
            ]

        try:
            self._last_mtime = self._dbcache.stat().st_mtime
        except OSError:
            pass

        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        size = self._dbcache.stat().st_size
        out_parts: list[str] = [
            f"{'=' * 100}",
            f"DBCache.bin -- {now}",
            f"Source: {self._dbcache}  ({size:,} bytes)",
            f"{'=' * 100}",
            "",
        ]

        # Decode
        if self._decode_script.exists():
            try:
                r = subprocess.run(
                    [sys.executable, str(self._decode_script), str(self._dbcache)],
                    capture_output=True, text=True, timeout=30,
                    cwd=str(self._wago_dir),
                )
                out_parts.append("--- DECODE ---\n")
                out_parts.append(r.stdout.rstrip() if r.stdout else "(no output)")
                if r.returncode != 0 and r.stderr:
                    out_parts.append(f"\n[exit {r.returncode}] {r.stderr.rstrip()}")
            except Exception as e:
                out_parts.append(f"[decode error] {e}")

        out_parts.append("")

        # Cross-reference
        if self._xref_script.exists():
            try:
                r = subprocess.run(
                    [sys.executable, str(self._xref_script)],
                    capture_output=True, text=True, timeout=120,
                    cwd=str(self._wago_dir),
                )
                out_parts.append("--- CROSS-REFERENCE (requires MySQL) ---\n")
                out_parts.append(r.stdout.rstrip() if r.stdout else "(no output)")
                if r.returncode != 0 and r.stderr:
                    out_parts.append(f"\n[exit {r.returncode}] {r.stderr.rstrip()}")
            except Exception as e:
                out_parts.append(f"[xref error] {e}")

        out_parts.append(f"\n{'=' * 100}\n")

        # Write output file directly (scanner-managed)
        self._output_dir.mkdir(parents=True, exist_ok=True)
        outfile = self._output_dir / "dbcache_decoded.txt"
        content = "\n".join(out_parts)
        atomic_write(outfile, content)

        return [
            ParsedEntry(
                timestamp=datetime.now().strftime("%H:%M:%S"),
                source=self.name,
                category="decoded",
                severity=Severity.INFO,
                text=f"DBCache.bin decoded ({size:,} bytes)",
                metadata={"size": size},
            )
        ]


def create(config: Config) -> DBCacheScanner:
    return DBCacheScanner(config)
