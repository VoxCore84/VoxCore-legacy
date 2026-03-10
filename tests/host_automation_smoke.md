# Host Automation Capability V1 - Smoke Validation

This document proves the primary acceptance criteria for the V1 Host Automation capability. 
All runs were executed on the Windows host natively via `python tools/host_automation/run_host_task.py`.

## 1. Localhost UI Automation
**Goal:** Automate the real localhost dashboard running on the host OS.

**Command:** 
```powershell
python tools\host_automation\run_host_task.py --url http://127.0.0.1:8765 --mode inspect
```

**Outcome (SUCCESS):**
```
Opening URL: http://127.0.0.1:8765
Page Title: Triad Command Center
Inspected DOM Length: 8014 bytes
Run run_9dd6ccd2 completed. Check logs/host_automation for outputs.
```
*Proves that Playwright running host-native correctly bypasses container loopback limitations and can reach the host Command Center.*

## 2. Public Web Automation
**Goal:** Perform a non-destructive navigation task on the open web.

**Command:**
```powershell
python tools\host_automation\run_host_task.py --url https://example.com --mode capture
```

**Outcome (SUCCESS):**
```
Opening URL: https://example.com
Page Title: Example Domain
Run run_b1694f81 completed. Check logs/host_automation for outputs.
```
*Proves wide internet connectivity and screenshot baseline capture.*

## 3. Failure Capture
**Goal:** Prove that the task layer cleanly handles failures and generates durable artifacts (manifest, exception trace, screenshot, HTML dump).

**Command:**
```powershell
python tools\host_automation\run_host_task.py --url http://127.0.0.1:9999 --mode capture
```

**Outcome (SUCCESSFUL FAILURE CAPTURE):**
- The script gracefully trapped `net::ERR_CONNECTION_REFUSED`
- `logs/host_automation/latest_run_manifest.json` correctly captured `status: "failed"` and the full Python exception trace
- `failure_screenshot_*.png` and `failure_dump_*.html` were saved into `logs/host_automation/runs/run_95a11242/`
- No zombie `chrome.exe` processes were left running.

## 4. PyWinAuto Fallback
**Goal:** Prove configuration and fallback hooks exist for pywinauto if needed in Edge cases.

- The `tools/host_automation/fallback_desktop.py` class successfully instantiated.
- The `healthcheck.py` successfully resolved PyWinAuto.
- Note: This is explicitly reserved for OS-level dialogues and pre-existing host applications.
