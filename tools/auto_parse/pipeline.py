"""Packet pipeline -- WPP + parse_sniff + packet_scope + parse_addon_data.

Triggered on server shutdown when World.pkt exists.
"""

from __future__ import annotations

import logging
import subprocess
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from .writers import atomic_write

if TYPE_CHECKING:
    from .config import Config

log = logging.getLogger("auto_parse")


class PacketPipeline:
    """Orchestrates the full packet analysis pipeline."""

    def __init__(self, config: Config) -> None:
        self._cfg = config.paths
        self._pkt = self._cfg.output_dir / "World.pkt"
        self._process_sniff = self._cfg.wago_dir / "process_sniff.py"
        self._parse_sniff = self._cfg.wago_dir / "parse_sniff.py"
        self._parse_addon = self._cfg.wago_dir / "parse_addon_data.py"
        self._packet_scope = self._cfg.tools_dir / "packet_scope.py"
        self._wpp_exe = self._cfg.wpp_exe

    def run(self, console_print=print) -> bool:
        """Run the full packet pipeline. Returns True on success."""
        if not self._pkt.exists():
            console_print("  [pipeline] No World.pkt -- skipping")
            return False

        pkt_size = self._pkt.stat().st_size
        if pkt_size < 100:
            console_print(f"  [pipeline] World.pkt too small ({pkt_size} bytes) -- skipping")
            return False

        console_print(f"  [pipeline] World.pkt ({pkt_size:,} bytes) -- starting pipeline...")
        success = True
        out_dir = self._cfg.output_dir

        # Option A: Unified process_sniff.py
        if self._process_sniff.exists():
            console_print("  [pipeline] Running process_sniff.py...")
            try:
                r = subprocess.run(
                    [sys.executable, str(self._process_sniff), str(self._pkt), "--no-import"],
                    capture_output=True, text=True, timeout=1800,
                    cwd=str(self._cfg.wago_dir),
                )
                console_print(f"  [pipeline] process_sniff exit={r.returncode}")
                if r.stdout:
                    atomic_write(out_dir / "pipeline_output.txt", r.stdout)
                if r.returncode != 0:
                    log.error("process_sniff failed: %s", r.stderr[:500])
                    success = False
            except subprocess.TimeoutExpired:
                console_print("  [pipeline] process_sniff timed out (30 min)")
                success = False
            except Exception as e:
                console_print(f"  [pipeline] process_sniff error: {e}")
                success = False
        else:
            # Option B: Run tools individually
            success = self._run_individual_tools(console_print)

        # Always run packet_scope for transmog analysis
        if self._packet_scope.exists():
            console_print("  [pipeline] Running packet_scope.py...")
            try:
                r = subprocess.run(
                    [sys.executable, str(self._packet_scope), "--pkt-dir", str(out_dir)],
                    capture_output=True, text=True, timeout=120,
                )
                if r.stdout:
                    atomic_write(out_dir / "packetscope_report.txt", r.stdout)
            except Exception as e:
                console_print(f"  [pipeline] packet_scope error: {e}")

        return success

    def _run_individual_tools(self, console_print) -> bool:
        """Fallback: run WPP, parse_sniff, parse_addon individually."""
        success = True
        out_dir = self._cfg.output_dir

        if self._wpp_exe.exists():
            console_print("  [pipeline] Running WPP...")
            try:
                r = subprocess.run(
                    [str(self._wpp_exe), str(self._pkt)],
                    capture_output=True, text=True, timeout=1800,
                    cwd=str(self._cfg.wpp_dir),
                )
                if r.returncode != 0:
                    success = False
            except Exception as e:
                console_print(f"  [pipeline] WPP error: {e}")
                success = False

        parsed_txt = out_dir / "World_parsed.txt"
        if not parsed_txt.exists():
            parsed_txt = out_dir / "World.pkt_parsed.txt"

        if self._parse_sniff.exists() and parsed_txt.exists():
            console_print("  [pipeline] Running parse_sniff.py...")
            try:
                subprocess.run(
                    [sys.executable, str(self._parse_sniff), str(parsed_txt),
                     "--json", "--out", str(out_dir / "sniff_import.sql")],
                    capture_output=True, text=True, timeout=300,
                    cwd=str(self._cfg.wago_dir),
                )
            except Exception as e:
                console_print(f"  [pipeline] parse_sniff error: {e}")

        if self._parse_addon.exists():
            console_print("  [pipeline] Running parse_addon_data.py...")
            try:
                subprocess.run(
                    [sys.executable, str(self._parse_addon),
                     "--out", str(out_dir / "addon_import.sql")],
                    capture_output=True, text=True, timeout=60,
                    cwd=str(self._cfg.wago_dir),
                )
            except Exception as e:
                console_print(f"  [pipeline] parse_addon error: {e}")

        return success


        return success
