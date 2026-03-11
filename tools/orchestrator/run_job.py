import os
import sys
import time
import argparse
from pathlib import Path

# Fix module resolution
_CURRENT_DIR = Path(__file__).resolve().parent
if str(_CURRENT_DIR) not in sys.path:
    sys.path.insert(0, str(_CURRENT_DIR))

from utils import load_orchestrator_config, sanitize_cli_args, VOXCORE_ROOT
from locks import OrchestratorLock
from write_manifest import create_run_id, init_manifest, add_transition, finalize_manifest
from read_state import snapshot_central_brain
from job_registry import resolve_adapter, get_approved_jobs

def parse_args():
    parser = argparse.ArgumentParser(description="Triad Orchestrator Control Plane")
    parser.add_argument("--job", required=True, help="The approved job to route to")
    parser.add_argument("--task-ref", help="Optional reference back to a specific task block")
    parser.add_argument("--dry-run", action="store_true", help="Validate routing and state without calling the tools")
    parser.add_argument("--clear-stale-lock", action="store_true", help="Force clear an existing orchestrator lock")
    parser.add_argument("--no-lock", action="store_true", help="Bypass the orchestrator singleton lock (allows parallel execution)")
    
    # Generic pass-through arguments for the adapters
    parser.add_argument("--preset", help="Build preset to use")
    parser.add_argument("--target", help="Build target to use")
    parser.add_argument("--configuration", help="Build config to use")
    parser.add_argument("--intake", help="Path to the Architect intake packet")
    parser.add_argument("--spec_file", help="Path to the Claude Code spec file")
    parser.add_argument("--mode", help="Mode for the Architect job")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--no-extract", action="store_true")

    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    config_data = load_orchestrator_config()
    
    # Run Generation
    run_id = create_run_id()
    manifest = init_manifest(run_id, args.job, config_data)
    manifest["task_ref"] = args.task_ref
    
    # Validating Job
    if args.job not in get_approved_jobs(config_data):
        print(f"ERROR: Job '{args.job}' is not an approved orchestrator route.")
        sys.exit(1)
        
    manifest["cli_args_sanitized"] = sanitize_cli_args(vars(args), args.job, config_data)
    add_transition(manifest, "validated")
    
    # Acquiring Global Lock
    if not args.no_lock:
        lock = OrchestratorLock(config_data.get("lock_file", "logs/orchestrator/locks/current.lock"), run_id, args.job)
        if not lock.acquire(force=args.clear_stale_lock):
            # We don't record a manifest for pure lock collisions to prevent spamming the logs
            sys.exit(1)
    else:
        lock = None
        
    try:
        add_transition(manifest, "lock_acquired")
        
        # State Snapshot
        brain_hash, brain_err = snapshot_central_brain(config_data)
        if brain_err:
            print(brain_err)
        manifest["central_brain_hash"] = brain_hash
        
        # Dispatch Adapter
        adapter_class = resolve_adapter(args.job, config_data)
        if not adapter_class:
            print(f"ERROR: No valid adapter found for {args.job}")
            finalize_manifest(manifest, config_data, exit_code=1, status_override="failed")
            sys.exit(1)
            
        adapter = adapter_class(config_data, manifest, args)
        
        if args.dry_run:
            print(f"DRY-RUN: Orchestrator validated plan for '{args.job}' (Run {run_id}). Bypassing execution.")
            finalize_manifest(manifest, config_data, exit_code=0, status_override="dry-run")
            return
            
        add_transition(manifest, "executing")
        exit_code, fingerprint = adapter.execute()
        
        finalize_manifest(manifest, config_data, exit_code=exit_code, capture_fingerprint=fingerprint)
        
        if exit_code != 0:
            sys.exit(exit_code)
            
    finally:
        if not args.no_lock and lock:
            lock.release()

if __name__ == "__main__":
    main()
