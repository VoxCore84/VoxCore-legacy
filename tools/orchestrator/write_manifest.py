import os
import json
import uuid
import time
import shutil
from pathlib import Path
from utils import VOXCORE_ROOT

def create_run_id():
    """Generates a unique sortable ID for the orchestrator run."""
    timestamp = time.strftime('%Y%m%d_%H%M%S')
    short_uuid = str(uuid.uuid4())[:8]
    return f"{timestamp}_{short_uuid}"

def init_manifest(run_id, job_name, config_data):
    """Bootstraps the initial pre-execution manifest dict."""
    return {
        "run_id": run_id,
        "job_name": job_name,
        "status": "executing",
        "started_at": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
        "ended_at": None,
        "duration_ms": 0,
        "invoked_by": os.environ.get("USERNAME", "unknown"),
        "cli_args_sanitized": {},
        "central_brain_hash": "",
        "central_brain_path": str(VOXCORE_ROOT / config_data.get("central_brain", "")),
        "task_ref": None,
        "artifacts_created": [],
        "downstream_log_paths": [],
        "exit_code": None,
        "failure_fingerprint": None,
        "transitions": [
            {
                "state": "requested",
                "timestamp": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
            }
        ]
    }

def add_transition(manifest, state_name):
    """Records a state transition in the manifest."""
    manifest["transitions"].append({
        "state": state_name,
        "timestamp": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    })

def atomic_write_json(file_path_obj, data):
    """Writes JSON atomically using a .tmp file."""
    tmp_path = file_path_obj.with_suffix(".tmp")
    try:
        with open(tmp_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
        shutil.move(str(tmp_path), str(file_path_obj))
    except Exception as e:
        print(f"ERROR appending to manifest {file_path_obj}: {e}")

def write_manifest_files(manifest, config_data):
    """
    Writes the specific per-run manifest and updates the 'latest' pointers.
    Generates both JSON and MD formats.
    """
    # Create the run directory based on today's date
    date_str = time.strftime('%Y-%m-%d')
    runs_dir = VOXCORE_ROOT / config_data.get("manifest_dir", "logs/orchestrator/runs") / date_str
    runs_dir.mkdir(parents=True, exist_ok=True)
    
    run_id = manifest["run_id"]
    json_path = runs_dir / f"{run_id}__manifest.json"
    md_path = runs_dir / f"{run_id}__summary.md"
    
    # 1) Write specific run manifest
    atomic_write_json(json_path, manifest)
    
    # 2) Generate Markdown summary
    md_content = f"""# Triad Orchestrator Run: {run_id}

**Job**: `{manifest["job_name"]}`
**Status**: `{manifest["status"].upper()}`
**invoked_by**: {manifest.get("invoked_by")}
**Duration (ms)**: {manifest.get("duration_ms", 0)}
**Exit Code**: {manifest.get("exit_code")}

## State Transitions
"""
    for t in manifest["transitions"]:
        md_content += f"- **{t['state']}** at `{t['timestamp']}`\n"
        
    if manifest.get("failure_fingerprint"):
        md_content += f"\n## Failure Fingerprint\n```json\n{json.dumps(manifest['failure_fingerprint'], indent=2)}\n```\n"

    tmp_md_path = md_path.with_suffix(".tmp")
    try:
        with open(tmp_md_path, "w", encoding="utf-8") as f:
            f.write(md_content)
        shutil.move(str(tmp_md_path), str(md_path))
    except Exception as e:
        print(f"ERROR appending to MD manifest {md_path}: {e}")

    # 3) Update "latest" pointers
    latest_json_path = VOXCORE_ROOT / config_data.get("latest_manifest", "logs/orchestrator/latest_run_manifest.json")
    latest_md_path = VOXCORE_ROOT / config_data.get("latest_summary", "logs/orchestrator/latest_run_summary.md")
    
    latest_json_path.parent.mkdir(parents=True, exist_ok=True)
    atomic_write_json(latest_json_path, manifest)
    
    try:
        shutil.copy2(str(md_path), str(latest_md_path))
    except Exception as e:
        print(f"ERROR updating latest pointers: {e}")

def finalize_manifest(manifest, config_data, exit_code, status_override=None, capture_fingerprint=None):
    """Calculates final timings, status, and writes out all files to disk."""
    end_time_float = time.time()
    manifest["ended_at"] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(end_time_float))
    manifest["exit_code"] = exit_code
    
    try:
        import calendar
        start_struct = time.strptime(manifest["started_at"], '%Y-%m-%dT%H:%M:%SZ')
        start_float = calendar.timegm(start_struct)
        manifest["duration_ms"] = int((end_time_float - start_float) * 1000)
    except:
        manifest["duration_ms"] = 0
        
    if status_override:
        manifest["status"] = status_override
    else:
        manifest["status"] = "succeeded" if exit_code == 0 else "failed"
        
    if capture_fingerprint and exit_code != 0:
        manifest["failure_fingerprint"] = capture_fingerprint
        
    add_transition(manifest, manifest["status"])
    write_manifest_files(manifest, config_data)
