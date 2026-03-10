import subprocess
import os
import sys
from pathlib import Path

_CURRENT_DIR = Path(__file__).resolve().parent
VOXCORE_ROOT = _CURRENT_DIR
while VOXCORE_ROOT.name != "VoxCore" and VOXCORE_ROOT.parent != VOXCORE_ROOT:
    VOXCORE_ROOT = VOXCORE_ROOT.parent

if VOXCORE_ROOT.name != "VoxCore":
    VOXCORE_ROOT = Path(os.getcwd())

def delegate_to_orchestrator(job_name, form_data):
    """
    Safely maps a web request down to the master CLI orchestrator.
    Does NOT block the Flask process. Fires and returns.
    """
    run_job_script = VOXCORE_ROOT / "tools" / "orchestrator" / "run_job.py"
    
    cmd = [sys.executable, str(run_job_script), "--job", job_name]
    
    # Map form fields to explicit CLI arguments depending on the job
    if job_name == "headless_build":
        preset = form_data.get("preset")
        if preset:
            cmd.extend(["--preset", preset])
            
        if form_data.get("dry_run") == "true":
            cmd.append("--dry-run")
            
    elif job_name == "architect_spec":
        intake = form_data.get("intake")
        if intake:
            cmd.extend(["--intake", intake])
            
        mode = form_data.get("mode")
        if mode:
            cmd.extend(["--mode", mode])
            
        if form_data.get("dry_run") == "true":
            cmd.append("--dry-run")
            
    elif job_name == "claude_implement":
        spec_file = form_data.get("spec_file")
        if spec_file:
            cmd.extend(["--spec_file", spec_file])
            
        if form_data.get("dry_run") == "true":
            cmd.append("--dry-run")
            
    elif job_name == "auto_retry_loop":
        spec_file = form_data.get("spec_file")
        if spec_file:
            cmd.extend(["--spec_file", spec_file])
            
        preset = form_data.get("preset")
        if preset:
            cmd.extend(["--preset", preset])
            
        if form_data.get("dry_run") == "true":
            cmd.append("--dry-run")
            
    print(f"WEB_UI: Delegating -> {' '.join(cmd)}")
    
    try:
        # Popen so we don't block the UI rendering waiting for a 15 min build
        subprocess.Popen(
            cmd,
            cwd=str(VOXCORE_ROOT),
            stdout=subprocess.DEVNULL,  # Orchestrator handles its own log captures
            stderr=subprocess.DEVNULL
        )
        return True, "Job requested. Poll manifests for status."
    except Exception as e:
        return False, str(e)
