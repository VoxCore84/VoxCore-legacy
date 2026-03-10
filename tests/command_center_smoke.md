# Smoke Validation: Command Center Operator Surface

*Date*: 2026-03-09
*Target*: `TRIAD-CMD-V1`

## Test Goals
Prove that the local Flask web dashboard bounds the Triad Orchestrator commands cleanly without background daemons, safely triggers jobs via the subprocess, and accurately renders durable JSON manifests.

## Test Matrix

| ID | Test Case | Expected Result | Status |
|---|---|---|---|
| TR-CMD-01 | **Server Boot** | `python tools/command_center/app.py` boots cleanly on `127.0.0.1:8765` without blocking. | **[PASS]** (Automated HTTP text validation verified 200 OK) |
| TR-CMD-02 | **UI Data Surface** | Central Brain state and historic run manifests appear on the `/` index. | **[PENDING]** (Manual Review Req) |
| TR-CMD-03 | **Dry-Run Submission** | Submitting a Dry-Run via `/jobs/architect_spec` safely delegates to the Orchestrator without invoking OpenAI. | **[PENDING]** (Manual Review Req) |
| TR-CMD-04 | **Run Detail Rendering**| Refreshing `/runs/<run_id>` shows the latest state transitions and exit code accurately. | **[PENDING]** (Manual Review Req) |
| TR-CMD-05 | **No Daemonization** | Hitting `CTRL+C` on the Flask process cleanly closes the application, leaving nothing running in the background. | **[PENDING]** (Manual Review Req) |

## Notes
- Automated UI validation failed due to an environmental limitation with the headless browser agent dropping localhost DOM sessions.
- Operator verification is required for final sign-off.
