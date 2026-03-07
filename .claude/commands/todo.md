# Show To-Do List

Display the current to-do list from memory.

## Tools

Read

## Instructions

Read `C:\Users\atayl\.claude\projects\C--Users-atayl-VoxCore\memory\todo.md` and display it to the user.

Format the output cleanly:
1. Show the `## Next Session` section first (if it exists), highlighted as the priority focus
2. Then show `## HIGH` items (skip any that are fully struck through / DONE)
3. Then show `## MEDIUM` items (skip DONE)
4. Then show `## LOW` items (skip DONE)
5. Skip `## Completed (archive)` and `## DEFERRED / BLOCKED` entirely unless the user passes "all" or "full" in `$ARGUMENTS`

Keep the output concise — strip the markdown strikethrough formatting from DONE items and just omit them. Show active items only by default.

If the user passes "add [item]" in `$ARGUMENTS`, add the item to the appropriate section (default HIGH) in todo.md and confirm.

If the user passes "done [item text]" in `$ARGUMENTS`, find the matching item in todo.md, mark it as `~~strikethrough~~ DONE`, and confirm.
