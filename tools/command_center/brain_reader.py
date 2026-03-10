import os
from pathlib import Path

_CURRENT_DIR = Path(__file__).resolve().parent
VOXCORE_ROOT = _CURRENT_DIR
while VOXCORE_ROOT.name != "VoxCore" and VOXCORE_ROOT.parent != VOXCORE_ROOT:
    VOXCORE_ROOT = VOXCORE_ROOT.parent

if VOXCORE_ROOT.name != "VoxCore":
    VOXCORE_ROOT = Path(os.getcwd())


def parse_central_brain():
    """
    Parses the Central Brain markdown to extract the Current Active Tabs
    and Completed Today sections for quick UI visibility.
    """
    brain_path = VOXCORE_ROOT / "AI_Studio" / "0_Central_Brain.md"
    
    if not brain_path.exists():
        return {"error": "Central Brain not found."}
        
    state = {
        "active_tabs": [],
        "completed_today": []
    }
    
    current_section = None
    
    try:
        with open(brain_path, "r", encoding="utf-8") as f:
            for line in f:
                stripped = line.strip()
                
                if stripped.startswith("## Current Active Tabs"):
                    current_section = "active_tabs"
                    continue
                elif stripped.startswith("## Completed Today"):
                    current_section = "completed_today"
                    continue
                elif stripped.startswith("## "):
                    current_section = None
                    
                if current_section and stripped:
                    state[current_section].append(stripped)
                    
        return state
    except Exception as e:
        return {"error": f"Failed to read Central Brain: {e}"}
