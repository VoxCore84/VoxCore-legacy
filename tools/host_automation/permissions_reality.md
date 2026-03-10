# Permissions & Execution Reality (Findings Note)

**Why sandbox/browser-subagent localhost failed:**
The AI agent operates in a sandboxed or containerized environment that does not share the same network namespace or desktop session as the user's host OS. Attempting to navigate to `http://localhost:8765` from within the sandbox hits the sandbox's own loopback interface, not the Windows host where the Command Center and other local services actually run. The subagent also lacks the ability to reach out of its sandbox to manipulate the host's Windows GUI.

**Why host-side Playwright is the right primary fix:**
Playwright running natively on the Windows host (via the Python environment available to the Orchestrator/Command Center) executes exactly where the target services run. It provides robust, deterministic browser automation that can easily hit the host's loopback interface, bypass sandbox network restrictions naturally, and interact with the real DOM of local and public sites.

**When pywinauto is actually needed:**
`pywinauto` is strictly a fallback layer for edge cases that happen outside the browser viewport. Examples include focusing an already-open Windows application, handling OS-level dialogs (like file pickers or native auth prompts that Playwright can't hook into), or interacting directly with desktop application windows (e.g., worldserver command prompts) when a browser interface is insufficient. It should remain tightly bounded.

**Why this must remain a separate reusable capability:**
Baking this directly into the Command Center web app limits its utility. By building it as a separate `tools/host_automation` package, the Orchestrator can treat host browser tasks as just another job type. It allows CLI invocation, integration with admin tools, and keeps the Command Center focused as an operator surface rather than an automation engine. It respects the Triad architecture of bounded, single-responsibility modules.
