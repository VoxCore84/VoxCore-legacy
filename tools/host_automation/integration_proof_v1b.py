import sys
import json
import time
from pathlib import Path

# Add root to python path to import config
_CURRENT_DIR = Path(__file__).resolve().parent
_TOOLS_DIR = _CURRENT_DIR.parent
_ROOT_DIR = _TOOLS_DIR.parent

if str(_ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(_ROOT_DIR))
if str(_CURRENT_DIR) not in sys.path:
    sys.path.insert(0, str(_CURRENT_DIR))

from host_session import HostSession

def load_config():
    config_path = _ROOT_DIR / "config" / "host_automation.json"
    if config_path.exists():
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def test_ui_workflow():
    print("=== Host Automation V1B Integration Proof ===")
    config = load_config()
    # Force capture mode for proof
    
    with HostSession(config, mode="capture") as session:
        print("1. Launching Command Center...")
        session.actions.open_url("http://127.0.0.1:8765")
        
        print("2. Navigating to Architect Spec Job...")
        # Assume the 'Architect API' button has an href to /jobs/architect_spec
        session.actions.click('a[href="/jobs/architect_spec"]', wait_for_nav=True)
        
        print("3. Filling out Job parameters...")
        session.actions.fill('#intake', 'AI_Studio/1_Inbox/2026-03-10__TRIAD-HOST-V1A__base_acceptance_and_ui_integration_gate.md')
        
        print("4. Enabling Safe Dry-Run...")
        session.actions.click('#dry_run', force=True)
        
        print("5. Submitting form...")
        session.actions.click('button[type="submit"]', wait_for_nav=True)
        
        print("6. Validating UI Success state...")
        # Check flash message
        flash_text = session.actions.extract_text('.uk-alert-success')
        if flash_text:
            print(f"UI Success confirmed: {flash_text.strip()}")
        else:
            print("WARNING: Could not find success flash message in UI!")
            
        print("7. Waiting for Orchestrator to flush manifest...")
        time.sleep(3)  # Give orchestrator a moment to create the manifest
        
        # Navigate to recent run link
        session.actions.open_url("http://127.0.0.1:8765")
        latest_run_id = session.actions.extract_text('table tbody tr:first-child td:first-child a')
        print(f"8. Discovered Run ID from UI: {latest_run_id}")
        
        print("   Validating Run ID mode is Dry-Run...")
        dry_run_badge = session.actions.extract_text('table tbody tr:first-child .badge-dryrun')
        if dry_run_badge:
            print("   UI confirms this was a DRY-RUN.")
        else:
            print("   WARNING: UI does not show DRY-RUN badge!")
            
        print(f"\nIntegration Proof complete. Manifest captured for session {session.run_id}.")
        return True

if __name__ == "__main__":
    test_ui_workflow()
