# The AI Orchestrator Plan

## 1. The Bottleneck: Manual Tab Management
The foundational Triad AI setup requires spinning up multiple UI instances: web browsers for ChatGPT/Gemini, a terminal window for Claude Code, and desktop application windows for Antigravity. 
This causes severe "copy-paste tax" and race conditions over shared files (like `0_Central_Brain.md`), capping the scaling capability of VoxCore Enterprise.

## 2. The Solution: Headless Orchestration (`orchestrator.py`)
To bypass manual intervention, VoxCore has prototyped a Python-based orchestrator script leveraging the **Microsoft AutoGen** / **LangGraph** concepts.

### Workflow:
1. **User Input:** The human developer executes a single terminal command: `python orchestrator.py "Make the discord bot respond to !ping"`.
2. **API Handshake (Architect):** The script queries the Google Vertex API (`gemini-1.5-pro`) to generate the feature specification in memory.
3. **Execution Loop (Claude / Anthropic API):** The script parses the spec string and passes it into the Anthropic API (`claude-3-5-sonnet`) equipped with local python filesystem tools. The Executor modifies the code.
4. **Verification Loop (Auditor API):** The script captures the `git diff` of the Executor's changes, passes it to a separate Anthropic API session (the Auditor), and compares it to the spec in memory.
5. **Autonomy:** If the Auditor returns `FAIL`, the script automatically feeds the failure reasons back into the Executor and loops up to 3 times before abandoning the task. 

## 3. Migration Roadmap
- [x] Prove the Triad workflow logic using manual UI tabs (Transmog Bridge & TQ Formatter features).
- [x] Prove the Blackboard sync using `0_Central_Brain.md`.
- [x] Suspend (Pause) all manual UI tabs safely.
- [x] Write the skeleton `orchestrator.py` script loading OpenAI/Anthropic/Vertex keys.
- [ ] Implement filesystem and terminal execution tools (Function Calling) for the Executor.
- [ ] Route the Auditor to read local git diffs for verification.
