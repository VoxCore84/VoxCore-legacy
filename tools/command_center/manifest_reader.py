import json
import os
from pathlib import Path
from brain_reader import VOXCORE_ROOT

def get_orchestrator_config():
    """Loads the main orchestrator config to find the manifest directory."""
    config_path = VOXCORE_ROOT / "config" / "orchestrator.json"
    if not config_path.exists():
        return {}
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}

def get_latest_manifest():
    """Returns the single latest run manifest JSON."""
    config = get_orchestrator_config()
    latest_path = VOXCORE_ROOT / config.get("latest_manifest", "logs/orchestrator/latest_run_manifest.json")
    
    if not latest_path.exists():
        return None
        
    try:
        with open(latest_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"Error reading latest manifest: {e}")
        return None

def get_recent_manifests(limit=10):
    """Scans the orchestrator runs directory and returns the `limit` most recent JSON manifests."""
    config = get_orchestrator_config()
    runs_dir = VOXCORE_ROOT / config.get("manifest_dir", "logs/orchestrator/runs")
    
    if not runs_dir.exists():
        return []
        
    # Gather all JSON manifests
    all_json_files = []
    try:
        for date_dir in runs_dir.iterdir():
            if date_dir.is_dir():
                for manifest_file in date_dir.glob("*__manifest.json"):
                    all_json_files.append(manifest_file)
    except Exception as e:
        print(f"Error scanning run dirs: {e}")
        return []

    # Sort files by modification time descending
    all_json_files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    
    recent_runs = []
    for file_path in all_json_files[:limit]:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                recent_runs.append(json.load(f))
        except:
            continue
            
    return recent_runs

def get_manifest_by_id(run_id):
    """Searches for a specific run ID manifest."""
    # Since we organize by date, we can just search all recent files or infer the date from the ID
    config = get_orchestrator_config()
    runs_dir = VOXCORE_ROOT / config.get("manifest_dir", "logs/orchestrator/runs")
    
    if not runs_dir.exists():
        return None
        
    for date_dir in runs_dir.iterdir():
        if date_dir.is_dir():
            target_file = date_dir / f"{run_id}__manifest.json"
            if target_file.exists():
                try:
                    with open(target_file, "r", encoding="utf-8") as f:
                        return json.load(f)
                except:
                    return None
                    
    return None
