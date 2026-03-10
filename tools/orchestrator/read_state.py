import os
import hashlib
from pathlib import Path
from utils import VOXCORE_ROOT

def snapshot_central_brain(config_data):
    """
    Reads the Central Brain file to compute a hash for the manifest.
    Remains strictly read-only.
    """
    brain_path = VOXCORE_ROOT / config_data.get("central_brain", "AI_Studio/0_Central_Brain.md")
    
    if not brain_path.exists():
        return "", f"WARNING: Central Brain not found at {brain_path}"
        
    try:
        with open(brain_path, "rb") as f:
            content = f.read()
            target_hash = hashlib.sha256(content).hexdigest()
            return target_hash, None
    except Exception as e:
        return "", f"ERROR reading Central Brain: {e}"
