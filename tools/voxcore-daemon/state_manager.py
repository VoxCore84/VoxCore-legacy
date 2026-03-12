"""
Atomic state file management with file locking and crash-safe writes.
All daemon state goes through this module — never write state files directly.
"""

import json
import msvcrt
import os
import time
import uuid
from pathlib import Path
from datetime import datetime
from contextlib import contextmanager


class StateManager:
    """Manages all daemon state files with atomic writes and file locking."""

    def __init__(self, state_dir: str):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self._lock_path = self.state_dir / ".daemon.lock"
        self._lock_fd = None

    # ── File Locking ──

    @contextmanager
    def global_lock(self):
        """Acquire a global process lock. All mutating workers must hold this."""
        lock_fd = open(self._lock_path, "w")
        try:
            msvcrt.locking(lock_fd.fileno(), msvcrt.LK_NBLCK, 1)
            lock_fd.write(f"{os.getpid()}\n{datetime.now().isoformat()}\n")
            lock_fd.flush()
            yield
        except OSError:
            lock_fd.close()
            raise RuntimeError("Another daemon instance holds the lock")
        finally:
            try:
                lock_fd.seek(0)
                msvcrt.locking(lock_fd.fileno(), msvcrt.LK_UNLCK, 1)
            except OSError:
                pass
            lock_fd.close()

    # ── Atomic Read/Write ──

    def _atomic_write(self, path: Path, data: str):
        """Write data to a file atomically via temp-write-and-rename."""
        tmp_path = path.with_suffix(path.suffix + ".tmp")
        tmp_path.write_text(data, encoding="utf-8")
        # On Windows, rename fails if target exists — remove first
        if path.exists():
            path.unlink()
        tmp_path.rename(path)

    def read_json(self, filename: str, default=None):
        """Read a JSON state file. Returns default if file doesn't exist."""
        path = self.state_dir / filename
        if not path.exists():
            return default if default is not None else {}
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return default if default is not None else {}

    def write_json(self, filename: str, data):
        """Write a JSON state file atomically."""
        path = self.state_dir / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        self._atomic_write(path, json.dumps(data, indent=2, default=str))

    def append_jsonl(self, filename: str, record: dict):
        """Append a single JSON record to a JSONL file."""
        path = self.state_dir / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        line = json.dumps(record, default=str) + "\n"
        with open(path, "a", encoding="utf-8") as f:
            f.write(line)

    # ── Run ID Generation ──

    def generate_run_id(self) -> str:
        """Generate a unique run ID: YYYYMMDD-HHMMSS-<short_uuid>."""
        ts = datetime.now().strftime("%Y%m%d-%H%M%S")
        short_id = uuid.uuid4().hex[:8]
        return f"{ts}-{short_id}"

    # ── Daemon State ──

    def get_daemon_state(self) -> dict:
        return self.read_json("daemon_state.json", {
            "status": "stopped",
            "pid": None,
            "started_at": None,
            "last_heartbeat": None,
            "managed_pids": {},
            "active_worker": None,
        })

    def update_daemon_state(self, **updates):
        state = self.get_daemon_state()
        state.update(updates)
        state["last_heartbeat"] = datetime.now().isoformat()
        self.write_json("daemon_state.json", state)

    # ── Active Run Tracking (crash recovery) ──

    def start_run(self, run_id: str, task_id: str, worker: str):
        """Record an active run for crash recovery."""
        self.write_json("active_run.json", {
            "run_id": run_id,
            "task_id": task_id,
            "worker": worker,
            "started_at": datetime.now().isoformat(),
            "status": "running",
        })

    def complete_run(self, run_id: str, status: str = "completed"):
        """Mark the active run as completed/failed."""
        active = self.read_json("active_run.json")
        if active and active.get("run_id") == run_id:
            active["status"] = status
            active["completed_at"] = datetime.now().isoformat()
            self.write_json("active_run.json", active)

    def check_interrupted_run(self) -> dict | None:
        """Check if there's an interrupted run from a previous daemon crash."""
        active = self.read_json("active_run.json")
        if active and active.get("status") == "running":
            return active
        return None

    # ── Run History ──

    def log_run(self, run_id: str, worker: str, task_id: str, status: str,
                details: dict | None = None):
        """Append a run record to the JSONL history."""
        record = {
            "run_id": run_id,
            "worker": worker,
            "task_id": task_id,
            "status": status,
            "timestamp": datetime.now().isoformat(),
        }
        if details:
            record["details"] = details
        self.append_jsonl("run_history.jsonl", record)

    # ── Work Queue ──

    def get_queue(self) -> list:
        return self.read_json("work_queue.json", [])

    def enqueue(self, item: dict):
        """Add an item to the work queue."""
        queue = self.get_queue()
        item.setdefault("queued_at", datetime.now().isoformat())
        item.setdefault("status", "pending")
        queue.append(item)
        # Sort by priority (lower = higher priority)
        queue.sort(key=lambda x: x.get("priority", 999))
        self.write_json("work_queue.json", queue)

    def dequeue(self) -> dict | None:
        """Pop the highest-priority pending item from the queue."""
        queue = self.get_queue()
        for i, item in enumerate(queue):
            if item.get("status") == "pending":
                queue[i]["status"] = "in_progress"
                self.write_json("work_queue.json", queue)
                return queue[i]
        return None

    def update_queue_item(self, task_id: str, **updates):
        """Update a queue item by task_id."""
        queue = self.get_queue()
        for item in queue:
            if item.get("task_id") == task_id:
                item.update(updates)
                break
        self.write_json("work_queue.json", queue)

    # ── Seen Specs ──

    def get_seen_specs(self) -> set:
        data = self.read_json("seen_specs.json", {"seen": []})
        return set(data.get("seen", []))

    def mark_spec_seen(self, spec_name: str):
        seen = self.get_seen_specs()
        seen.add(spec_name)
        self.write_json("seen_specs.json", {"seen": sorted(seen)})

    # ── Last Good State ──

    def save_good_state(self, state: dict):
        self.write_json("last_good_state.json", {
            "saved_at": datetime.now().isoformat(),
            **state,
        })
