# Proactive Skill Reminders — MANDATORY

**The user should NEVER have to remember to run a slash command.** Remind at the right moment or just run it if unambiguous.

| Trigger | Action |
|---|---|
| "I'm done", wrapping up, conversation winding down | `/wrap-up` — ask or run |
| Server restart, crash, debugging begins | `/check-logs` — just run it |
| Build error pasted | `/parse-errors` — just run it |
| C++ file edited, work complete | Remind: "Ready to build in VS" |
| SQL file created/edited | `/smartai-check` (if SmartAI) or `/apply-sql` |
| Writing new SQL update | `/new-sql-update` — run for filename |
| Multiple tasks / scope expanding | Suggest tab split (see multi-tab rules) |
| Session start | Auto-read `doc/session_state.md` + `todo.md` |
| Name without ID (spell/item/creature/area) | Run `/lookup-*` to resolve |
| Addon/tool/app approaching "done" state | `/pre-ship` — remind before commit |
| Writing to `tools/publishable/` directory | `/pre-ship` — ask if ready for audit |
| User says "ship it", "release", "v1.0", "zip it up" | `/pre-ship` — run before packaging |
| Working on Case_Reference or legal case files | `/case-status` — run at session start for case work |
| User pastes output from ChatGPT/Gemini/Grok for case | Spawn `case-intake` agent to parse and plan edits |
| User asks "who handles X" or "which lawyer" | `/lane-map` — show legal lane ownership |
| User asks for a summary, brief, or one-pager | `/one-pager [audience]` — generate executive summary |
| User mentions .mbox, Gmail export, email archive | `/mbox-parse` — index and search |
| User mentions deadline, "how many days", ADSCD | `/deadlines` — show countdown |
| User asks to find evidence or verify a claim | `/evidence-xref "claim"` — trace to source |
| User asks to search case files for a name/topic | `/case-search [term]` — search archive |
| User asks to sort/triage/organize files | Spawn `file-sorter` agent |
| User asks to read/ingest/analyze a folder of images | `python tools/ingest_images.py <dir>` — NEVER read images into conversation context |
| User needs to read a .docx file | `/read-doc [path]` — extract text |
| User asks about a specific person in the case | `/person-dossier [name]` — full mention search |
| User preparing a filing (DD7050, AFBCMR, NPDB, etc.) | `/filing-prep [type]` — draft with evidence citations |
| User asks "do we have evidence for X" before filing | `/evidence-gap [filing]` — requirements vs archive |
| User asks to update or regenerate the timeline | `/case-timeline [update]` — rebuild from all sources |

**Rules:**
- If in doubt, ask. A one-line reminder is cheap; forgetting `/wrap-up` loses work.
- Never skip `/wrap-up` at end of session.
- `/check-logs` is always safe to run proactively — read-only.
