import sys
import os
from pathlib import Path

# Add root to python path to import config
_CURRENT_DIR = Path(__file__).resolve().parent
_TOOLS_DIR = _CURRENT_DIR.parent
_ROOT_DIR = _TOOLS_DIR.parent

if str(_ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(_ROOT_DIR))
    
def check_playwright():
    print("Testing Playwright...")
    try:
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            print(f"Playwright installed. Available browsers:")
            if p.chromium: print("  - Chromium")
            if p.firefox: print("  - Firefox")
            if p.webkit: print("  - Webkit")
        return True
    except ImportError:
        print("ERROR: playwright python module not installed. Run: pip install playwright")
        return False
    except Exception as e:
        print(f"ERROR: Playwright failed to initialize: {e}")
        return False

def check_pywinauto():
    print("\nTesting pywinauto...")
    try:
        import pywinauto
        print(f"pywinauto installed (version {pywinauto.__version__})")
        return True
    except ImportError:
        print("WARNING: pywinauto not installed. Desktop fallback will be disabled. Run: pip install pywinauto")
        return False

def main():
    print("=== Host Automation Healthcheck ===\n")
    p_ok = check_playwright()
    w_ok = check_pywinauto()
    
    print("\n=== Summary ===")
    if p_ok and w_ok:
        print("All capabilities (Browser + Desktop) are ready.")
        sys.exit(0)
    elif p_ok:
        print("Browser capability ready. Desktop fallback unavailable.")
        sys.exit(0)
    else:
        print("CRITICAL: Primary browser capability (Playwright) is missing.")
        sys.exit(1)

if __name__ == "__main__":
    main()
