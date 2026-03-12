"""
BaseWorker: common infrastructure for all daemon workers.
Provides logging, state management, dry-run support, and run tracking.
"""

import logging
from abc import ABC, abstractmethod
from datetime import datetime

from state_manager import StateManager
from claude_api import ClaudeAPI
from notify import Notifier, Severity


class BaseWorker(ABC):
    """Base class for all daemon workers."""

    # Subclasses set this
    name: str = "base"

    def __init__(self, state: StateManager, api: ClaudeAPI, notifier: Notifier,
                 config: dict, dry_run: bool = False):
        self.state = state
        self.api = api
        self.notifier = notifier
        self.config = config
        self.dry_run = dry_run
        self.log = logging.getLogger(f"daemon.{self.name}")

    def execute(self, run_id: str, **kwargs) -> dict:
        """
        Execute the worker with full run tracking.
        Returns a result dict with at minimum {"status": "success"|"failed"|"skipped"}.
        """
        task_id = kwargs.get("task_id", "")
        self.log.info("Starting %s (run=%s, task=%s, dry_run=%s)",
                      self.name, run_id, task_id, self.dry_run)

        # Record active run
        self.state.start_run(run_id, task_id, self.name)

        try:
            result = self.run(run_id=run_id, **kwargs)
            status = result.get("status", "completed")

            # Log to history
            self.state.log_run(run_id, self.name, task_id, status, result)
            self.state.complete_run(run_id, status)

            if status == "failed":
                self.log.error("%s failed: %s", self.name, result.get("error", "unknown"))
                self.notifier.failure(
                    f"Worker Failed: {self.name}",
                    result.get("error", "Unknown error"),
                    run_id=run_id, task_id=task_id,
                )
            else:
                self.log.info("%s completed: %s", self.name, status)

            return result

        except Exception as e:
            self.log.exception("Unhandled exception in %s", self.name)
            error_msg = f"{type(e).__name__}: {e}"

            self.state.log_run(run_id, self.name, task_id, "error",
                               {"error": error_msg})
            self.state.complete_run(run_id, "error")

            self.notifier.failure(
                f"Worker Error: {self.name}",
                error_msg,
                run_id=run_id, task_id=task_id,
            )

            return {"status": "error", "error": error_msg}

    @abstractmethod
    def run(self, run_id: str, **kwargs) -> dict:
        """
        The actual worker logic. Subclasses implement this.

        Must return a dict with at minimum {"status": "success"|"failed"|"skipped"}.
        Check self.dry_run before performing any mutations.
        """
        ...

    def dry_run_skip(self, action: str) -> None:
        """Log a skipped action in dry-run mode."""
        self.log.info("[DRY-RUN] Skipping: %s", action)
