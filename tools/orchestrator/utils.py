import os
import sys
import json
from pathlib import Path

# Resolve VoxCore Root
_CURRENT_DIR = Path(__file__).resolve().parent
VOXCORE_ROOT = _CURRENT_DIR
while VOXCORE_ROOT.name != "VoxCore" and VOXCORE_ROOT.parent != VOXCORE_ROOT:
    VOXCORE_ROOT = VOXCORE_ROOT.parent

if VOXCORE_ROOT.name != "VoxCore":
    VOXCORE_ROOT = Path(os.getcwd())

def load_orchestrator_config():
    """Loads the main orchestrator.json config file."""
    config_path = VOXCORE_ROOT / "config" / "orchestrator.json"
    if not config_path.exists():
        print(f"ERROR: Cannot find orchestrator config at {config_path}")
        sys.exit(1)
        
    with open(config_path, "r", encoding="utf-8") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError as e:
            print(f"ERROR: Invalid JSON in {config_path}: {e}")
            sys.exit(1)

def sanitize_cli_args(args_dict, job_name, config):
    """
    Sanitizes CLI arguments for safe manifest inclusion.
    Ensures only expected flags are logged, redaction applied if necessary.
    """
    if job_name not in config.get("jobs", {}):
        return {}
        
    allowed = config["jobs"][job_name].get("allowed_flags", [])
    sanitized = {}
    
    for key, value in args_dict.items():
        if key in allowed and value is not None:
            # Simple secret redaction (just in case, though mostly handled by delegators)
            if "key" in key.lower() or "secret" in key.lower() or "token" in key.lower():
                sanitized[key] = "[REDACTED]"
            else:
                sanitized[key] = value
                
    return sanitized
