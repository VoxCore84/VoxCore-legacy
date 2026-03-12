"""
VoxCore Daemon — Autonomous DevOps Pipeline
Main entry point: scheduler, single-instance guard, signal handling.

Usage:
    python daemon.py              # Run in foreground
    python daemon.py --dry-run    # Dry-run mode (no mutations)
    pythonw daemon.py             # Run in background (no console)
"""

import argparse
import atexit
import json
import logging
import os
import signal
import sys
import time
from datetime import datetime
from pathlib import Path

# Ensure the daemon package is importable
DAEMON_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = DAEMON_DIR.parent.parent  # tools/voxcore-daemon -> VoxCore
sys.path.insert(0, str(DAEMON_DIR))
os.chdir(PROJECT_ROOT)

import tomllib
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.events import EVENT_JOB_ERROR, EVENT_JOB_EXECUTED
from dotenv import load_dotenv

from state_manager import StateManager
from claude_api import ClaudeAPI
from notify import Notifier, Severity
from idle_detector import IdleDetector


# ── Logging ──

def setup_logging(log_file: str):
    """Configure logging to both file and console."""
    log_dir = PROJECT_ROOT / Path(log_file).parent
    log_dir.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.FileHandler(PROJECT_ROOT / log_file, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )

log = logging.getLogger("daemon")


# ── Config Loading ──

def load_config() -> dict:
    """Load config.toml from the daemon directory."""
    config_path = DAEMON_DIR / "config.toml"
    if not config_path.exists():
        print(f"ERROR: Config not found: {config_path}")
        sys.exit(1)
    with open(config_path, "rb") as f:
        return tomllib.load(f)


def load_autonomy_policy() -> dict:
    """Load autonomy_policy.toml from the daemon directory."""
    policy_path = DAEMON_DIR / "autonomy_policy.toml"
    if not policy_path.exists():
        log.warning("Autonomy policy not found: %s — using defaults", policy_path)
        return {}
    with open(policy_path, "rb") as f:
        return tomllib.load(f)


# ── Secrets Validation ──

def validate_secrets(config: dict):
    """Validate that required environment variables are set. Fail fast."""
    required_env = []

    # API key
    if not os.environ.get("ANTHROPIC_API_KEY"):
        required_env.append("ANTHROPIC_API_KEY")

    # MySQL password
    pw_env = config.get("mysql", {}).get("password_env", "MYSQL_PASSWORD")
    if not os.environ.get(pw_env):
        log.warning("MySQL password env '%s' not set — SQL workers will be disabled", pw_env)

    # Discord webhook
    wh_env = config.get("notify", {}).get("discord_webhook_env", "DISCORD_WEBHOOK_URL")
    if not os.environ.get(wh_env):
        log.warning("Discord webhook env '%s' not set — Discord notifications disabled", wh_env)

    if required_env:
        log.error("Missing required environment variables: %s", required_env)
        print(f"ERROR: Set these environment variables: {', '.join(required_env)}")
        sys.exit(1)


# ── Single Instance Guard ──

LOCK_FILE = DAEMON_DIR / "state" / ".daemon.pid"


def acquire_single_instance():
    """Ensure only one daemon instance runs at a time."""
    LOCK_FILE.parent.mkdir(parents=True, exist_ok=True)

    if LOCK_FILE.exists():
        try:
            old_pid = int(LOCK_FILE.read_text().strip())
            # Check if the process is still running (Windows)
            import ctypes
            kernel32 = ctypes.windll.kernel32
            handle = kernel32.OpenProcess(0x1000, False, old_pid)  # PROCESS_QUERY_LIMITED_INFORMATION
            if handle:
                kernel32.CloseHandle(handle)
                print(f"ERROR: Another daemon is already running (PID {old_pid})")
                print(f"If this is stale, delete: {LOCK_FILE}")
                sys.exit(1)
        except (ValueError, OSError):
            pass  # Stale lock file, proceed

    LOCK_FILE.write_text(str(os.getpid()))


def release_single_instance():
    """Remove the PID lock file on exit."""
    try:
        if LOCK_FILE.exists():
            LOCK_FILE.unlink()
    except OSError:
        pass


# ── Startup Reconciliation ──

def reconcile_interrupted_runs(state: StateManager, notifier: Notifier):
    """Check for and handle interrupted runs from a previous daemon crash."""
    interrupted = state.check_interrupted_run()
    if interrupted:
        run_id = interrupted["run_id"]
        worker = interrupted["worker"]
        started = interrupted.get("started_at", "unknown")

        log.warning("Found interrupted run: %s (worker=%s, started=%s)",
                     run_id, worker, started)

        # Mark as interrupted — do NOT resume automatically
        state.complete_run(run_id, "interrupted")
        state.log_run(run_id, worker, interrupted.get("task_id", ""),
                       "interrupted", {"reason": "daemon restart"})

        notifier.warning(
            "Interrupted Run Detected",
            f"Run {run_id} (worker: {worker}) was interrupted by a daemon "
            f"restart. It has been marked as interrupted and will NOT be "
            f"resumed automatically.",
            run_id=run_id, worker=worker,
        )


# ── Scheduler Job Wrappers ──

class DaemonContext:
    """Shared context passed to all scheduled jobs."""

    def __init__(self, config: dict, policy: dict, state: StateManager,
                 api: ClaudeAPI, notifier: Notifier, idle: IdleDetector,
                 dry_run: bool):
        self.config = config
        self.policy = policy
        self.state = state
        self.api = api
        self.notifier = notifier
        self.idle = idle
        self.dry_run = dry_run


def job_heartbeat(ctx: DaemonContext):
    """Periodic heartbeat to update daemon state."""
    ctx.state.update_daemon_state(
        status="running",
        pid=os.getpid(),
    )


def job_inbox_triage(ctx: DaemonContext):
    """Scheduled inbox triage job. Phase 2 — stubbed for now."""
    log.info("InboxTriage job triggered (Phase 2 — not yet implemented)")


def job_check_queue(ctx: DaemonContext):
    """Check work queue and dispatch CodeWriter if user is away. Phase 3 — stubbed."""
    if not ctx.idle.is_user_away():
        log.debug("User is active — skipping queue processing")
        return
    log.info("Queue check triggered (user is away). Phase 3 — not yet implemented")


def job_log_monitor(ctx: DaemonContext):
    """Check server logs for errors/crashes. Phase 2 — stubbed."""
    log.debug("LogMonitor tick (Phase 2 — not yet implemented)")


def job_daily_standup(ctx: DaemonContext):
    """Generate daily standup report. Phase 2 — stubbed."""
    log.info("Daily standup triggered (Phase 2 — not yet implemented)")


def job_weekly_report(ctx: DaemonContext):
    """Generate weekly rollup report. Phase 2 — stubbed."""
    log.info("Weekly report triggered (Phase 2 — not yet implemented)")


def on_job_error(event):
    """Handle scheduler job errors."""
    log.error("Job %s raised: %s", event.job_id, event.exception)


def on_job_executed(event):
    """Handle scheduler job completion."""
    if event.retval:
        log.debug("Job %s completed: %s", event.job_id, event.retval)


# ── Main ──

def main():
    parser = argparse.ArgumentParser(description="VoxCore Daemon")
    parser.add_argument("--dry-run", action="store_true",
                        help="Run in dry-run mode (no mutations)")
    args = parser.parse_args()

    # Load config
    config = load_config()
    policy = load_autonomy_policy()
    dry_run = args.dry_run or config.get("daemon", {}).get("dry_run", False)

    # Setup logging
    log_file = config.get("daemon", {}).get("log_file", "logs/daemon/daemon.log")
    setup_logging(log_file)

    log.info("=" * 60)
    log.info("VoxCore Daemon starting%s", " [DRY-RUN]" if dry_run else "")
    log.info("Project root: %s", PROJECT_ROOT)
    log.info("Config loaded from: %s", DAEMON_DIR / "config.toml")
    log.info("=" * 60)

    # Load .env for API keys
    env_file = config.get("api", {}).get("env_file", "")
    if env_file:
        env_path = PROJECT_ROOT / env_file
        if env_path.exists():
            load_dotenv(env_path)
            log.info("Loaded env from: %s", env_path)

    # Also load from daemon dir
    daemon_env = DAEMON_DIR / ".env"
    if daemon_env.exists():
        load_dotenv(daemon_env)

    # Validate secrets
    validate_secrets(config)

    # Single-instance guard
    acquire_single_instance()
    atexit.register(release_single_instance)

    # Initialize components
    state_dir = str(PROJECT_ROOT / config.get("daemon", {}).get(
        "state_dir", "tools/voxcore-daemon/state"))
    state = StateManager(state_dir)

    api = ClaudeAPI(
        config=config.get("api", {}),
        prompts_dir=DAEMON_DIR / "prompts",
    )

    wh_env = config.get("notify", {}).get("discord_webhook_env", "DISCORD_WEBHOOK_URL")
    notifier = Notifier(
        discord_webhook_url=os.environ.get(wh_env),
        burnttoast_enabled=config.get("notify", {}).get("burnttoast_enabled", True),
    )

    idle_cfg = config.get("daemon", {})
    idle = IdleDetector(
        idle_threshold_minutes=idle_cfg.get("idle_threshold_minutes", 20),
        night_start_hour=idle_cfg.get("night_window_start", 23),
        night_end_hour=idle_cfg.get("night_window_end", 7),
        force_autonomous=idle_cfg.get("force_autonomous", False),
    )

    # Create shared context
    ctx = DaemonContext(config, policy, state, api, notifier, idle, dry_run)

    # Startup reconciliation
    reconcile_interrupted_runs(state, notifier)

    # Update daemon state
    state.update_daemon_state(
        status="running",
        pid=os.getpid(),
        started_at=datetime.now().isoformat(),
        dry_run=dry_run,
    )

    # Notify startup
    notifier.success(
        "Daemon Started",
        f"VoxCore Daemon is running (PID {os.getpid()}).\n"
        f"Mode: {'DRY-RUN' if dry_run else 'LIVE'}\n"
        f"Idle threshold: {idle_cfg.get('idle_threshold_minutes', 20)} min\n"
        f"Night window: {idle_cfg.get('night_window_start', 23)}:00-"
        f"{idle_cfg.get('night_window_end', 7)}:00",
    )

    # Setup scheduler
    schedules = config.get("schedules", {})
    scheduler = BlockingScheduler()

    # Heartbeat — every 5 minutes
    scheduler.add_job(job_heartbeat, "interval", minutes=5, args=[ctx],
                      id="heartbeat", misfire_grace_time=60)

    # InboxTriage — configurable interval (default 30 min)
    triage_min = schedules.get("inbox_triage_minutes", 30)
    scheduler.add_job(job_inbox_triage, "interval", minutes=triage_min,
                      args=[ctx], id="inbox_triage", misfire_grace_time=300)

    # Queue check — every 5 minutes (lightweight, just checks if work exists)
    scheduler.add_job(job_check_queue, "interval", minutes=5, args=[ctx],
                      id="queue_check", misfire_grace_time=60)

    # Log monitor — every 2 minutes
    scheduler.add_job(job_log_monitor, "interval", minutes=2, args=[ctx],
                      id="log_monitor", misfire_grace_time=60)

    # Daily standup
    standup_hour = schedules.get("daily_standup_hour", 8)
    scheduler.add_job(job_daily_standup, "cron", hour=standup_hour, minute=0,
                      args=[ctx], id="daily_standup", misfire_grace_time=3600)

    # Weekly report
    weekly_day = schedules.get("weekly_report_day", "sunday")
    weekly_hour = schedules.get("weekly_report_hour", 18)
    scheduler.add_job(job_weekly_report, "cron", day_of_week=weekly_day[:3],
                      hour=weekly_hour, minute=0, args=[ctx],
                      id="weekly_report", misfire_grace_time=3600)

    # Error handling
    scheduler.add_listener(on_job_error, EVENT_JOB_ERROR)
    scheduler.add_listener(on_job_executed, EVENT_JOB_EXECUTED)

    # Signal handling for graceful shutdown
    def shutdown_handler(signum, frame):
        log.info("Received signal %s — shutting down gracefully", signum)
        state.update_daemon_state(status="stopping")
        notifier.info("Daemon Stopping", f"Received signal {signum}. Shutting down.")
        scheduler.shutdown(wait=False)

    signal.signal(signal.SIGINT, shutdown_handler)
    signal.signal(signal.SIGTERM, shutdown_handler)

    # Run
    log.info("Scheduler starting with %d jobs", len(scheduler.get_jobs()))
    for job in scheduler.get_jobs():
        log.info("  Job: %s — %s", job.id, job.trigger)

    try:
        scheduler.start()
    except (KeyboardInterrupt, SystemExit):
        log.info("Daemon stopped.")
    finally:
        state.update_daemon_state(status="stopped")
        release_single_instance()
        log.info("Daemon exited cleanly.")


if __name__ == "__main__":
    main()
