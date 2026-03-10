# Permissions & Execution Reality

## Context
During the smoke validation of the Triad Command Center Operator Surface (Stream 4), an automated UI test via the AI Browser Subagent failed to hold the `localhost:8765` session open.

This document clarifies *why* this happens and establishes the rules of engagement for UI vs Backend execution.

## The Environment Boundary
The failure is **not** a missing Windows permission, nor is it a lack of internet access. It is an **execution context boundary**.

- **Why `localhost` works for the human operator:** The human opens `chrome.exe` natively on the Windows host OS, which shares the same network loopback (`127.0.0.1`) as the local Python Flask server driving the Command Center.
- **Why the AI Browser Subagent fails:** The AI Browser Subagent executes inside an isolated, containerized sandbox (e.g., a managed cloud Playwright context or containerized agentic runtime). Inside that sandbox, `localhost` points to the sandbox itself, not the Windows host. Therefore, the subagent cannot "see" the host's `8765` port.

## Execution Directives

1. **Current Permissions are Sufficient:** The agent already possesses the necessary permissions to execute host terminals, modify the file system, and invoke the OpenAI API. Do not request "more internet permissions" to fix sandbox network boundaries.
2. **Backend is the Primary AI Execution Path:** Because of this host-vs-sandbox boundary, AI automation (like the Orchestrator) must continue to rely on programmatic backend execution (CLI subprocesses, manifest generation, Python scripts). 
3. **Visual UI is for Humans:** Web UI surfaces like the Command Center are built for human ergonomics. Do not attempt to use the containerized Browser Subagent to automate local human dashboards.
4. **Host Browser Automation Requires a New Capability:** If the AI needs to drive a Chromium browser on the Windows host (to bypass Cloudflare, test local dashboards, etc.), it cannot use the isolated browser tooling. It must invoke a host-native Playwright or UI-automation script executed manually via the Orchestrator backend.
