import sys
import argparse
import json
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
from fallback_desktop import DesktopFallback

def load_config():
    config_path = _ROOT_DIR / "config" / "host_automation.json"
    if config_path.exists():
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def parse_args():
    parser = argparse.ArgumentParser(description="Host Automation Capability V1")
    parser.add_argument("--url", help="URL to open in the browser")
    parser.add_argument("--mode", choices=["inspect", "capture", "dry-run"], default="capture", help="Execution mode")
    parser.add_argument("--click", help="CSS Selector to click after load")
    parser.add_argument("--extract", help="CSS Selector to extract text from")
    parser.add_argument("--headless", action="store_true", help="Override config to force headless mode")
    parser.add_argument("--focus-window", help="Use pywinauto to focus a specific window title regex")
    
    return parser.parse_args()

def main():
    args = parse_args()
    config = load_config()
    
    if args.headless:
        config["headless"] = True

    # Desktop fallback path
    if args.focus_window:
        desktop = DesktopFallback(config)
        success = desktop.focus_window_by_title(args.focus_window)
        if success:
            print(f"SUCCESS: Focused window matching '{args.focus_window}'")
            sys.exit(0)
        else:
            print(f"FAILED: Could not focus window matching '{args.focus_window}'")
            sys.exit(1)

    # Browser automation path
    if not args.url:
        print("ERROR: --url is required for browser automation tasks.")
        sys.exit(1)

    with HostSession(config, mode=args.mode) as session:
        if args.mode == "dry-run":
            print(f"Dry-run mode. Validated URL: {args.url}")
            return
            
        print(f"Opening URL: {args.url}")
        result = session.actions.open_url(args.url)
        print(f"Page Title: {result['title']}")
        
        if args.mode == "inspect":
            data = session.actions.inspect_page()
            print(f"Inspected DOM Length: {data['html_length']} bytes")
            
        if args.click:
            print(f"Clicking: {args.click}")
            session.actions.click(args.click)
            
        if args.extract:
            text = session.actions.extract_text(args.extract)
            print(f"Extracted text for '{args.extract}': {text}")
            session.artifacts.record_action("extract", {"selector": args.extract, "result": text})

        print(f"Run {session.run_id} completed. Check {config.get('artifacts_dir', 'logs/host_automation')} for outputs.")

if __name__ == "__main__":
    main()
