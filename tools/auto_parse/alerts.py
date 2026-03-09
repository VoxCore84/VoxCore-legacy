"""Alert fingerprinting and deduplication.

Tracks seen error patterns so only truly NEW errors trigger alerts/notifications.
Persists the seen-set to a JSON file across restarts.
"""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path
from typing import TYPE_CHECKING

from .parsers.base import ParsedEntry, Severity

if TYPE_CHECKING:
    from .config import Config


def _fingerprint(entry: ParsedEntry) -> str:
    """Normalize an entry into a stable fingerprint for dedup.

    Strips numbers, GUIDs, and timestamps so the same *type* of error
    produces the same fingerprint regardless of specific IDs.
    """
    text = entry.text
    # Normalize numbers, hex values, GUIDs
    text = re.sub(r"0x[A-Fa-f0-9]+", "0xH", text)
    text = re.sub(r"\b\d+\b", "N", text)
    # Combine source + category + normalized text
    key = f"{entry.source}|{entry.category}|{text[:150]}"
    return hashlib.sha256(key.encode()).hexdigest()[:16]


class AlertManager:
    """Manages alert deduplication and notification dispatch."""

    def __init__(self, config: Config) -> None:
        self._seen_file = config.paths.seen_file
        self._suppress = config.alerts.suppress_known
        self._max_seen = config.alerts.max_seen
        self._notify_cfg = config.notifications
        self._seen: set[str] = set()
        self._suppressed_count = 0
        self._load_seen()

    def check_new(self, entries: list[ParsedEntry]) -> list[ParsedEntry]:
        """Filter entries to only truly new alert-worthy ones.

        Returns the list of new entries. Also triggers notifications.
        """
        new_alerts: list[ParsedEntry] = []

        for entry in entries:
            if entry.severity < Severity.ERROR:
                continue

            fp = _fingerprint(entry)

            if self._suppress and fp in self._seen:
                self._suppressed_count += 1
                continue

            self._seen.add(fp)
            new_alerts.append(entry)

            # Send notification for fatals/crashes
            if self._notify_cfg.enabled:
                self._maybe_notify(entry)

        # Persist after processing
        if new_alerts:
            self._save_seen()

        return new_alerts

    @property
    def suppressed_count(self) -> int:
        return self._suppressed_count

    @property
    def known_count(self) -> int:
        return len(self._seen)

    def _maybe_notify(self, entry: ParsedEntry) -> None:
        """Send a desktop notification if configured."""
        from .notify import send_toast

        if entry.severity >= Severity.FATAL and self._notify_cfg.on_fatal:
            send_toast(
                title=f"VoxCore {entry.source} FATAL",
                message=entry.text[:200],
            )
        elif entry.category == "crash_dump" and self._notify_cfg.on_crash:
            send_toast(
                title="VoxCore CRASH DETECTED",
                message=entry.text[:200],
            )
        elif entry.severity >= Severity.ERROR and self._notify_cfg.on_error:
            send_toast(
                title=f"VoxCore {entry.source} Error",
                message=entry.text[:200],
            )

    def _load_seen(self) -> None:
        if not self._seen_file.exists():
            return
        try:
            data = json.loads(self._seen_file.read_text(encoding="utf-8"))
            self._seen = set(data.get("fingerprints", []))
        except Exception:
            pass

    def _save_seen(self) -> None:
        # Evict oldest if too large (FIFO approximation via list slice)
        seen_list = list(self._seen)
        if len(seen_list) > self._max_seen:
            seen_list = seen_list[-self._max_seen:]
            self._seen = set(seen_list)

        data = {"fingerprints": seen_list}
        tmp = self._seen_file.with_suffix(".tmp")
        try:
            tmp.write_text(json.dumps(data), encoding="utf-8")
            tmp.replace(self._seen_file)
        except OSError:
            pass
