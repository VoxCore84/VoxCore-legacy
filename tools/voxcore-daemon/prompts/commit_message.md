# Commit Message Generation

Generate a semantic git commit message for the following changes.

## Task
{task_summary}

## Files Changed
{files_changed}

## Diff Summary
{diff_summary}

## Rules
- Use conventional commit format: `type(scope): description`
- Types: feat, fix, chore, refactor, docs, style, test
- Keep the first line under 72 characters
- Add a blank line then a body with:
  - What was changed and why
  - Task ID and run ID

## Required Output
Output ONLY the commit message (no markdown fencing, no explanation):

type(scope): short description

Longer description of what changed and why.

Task-ID: {task_id}
Run-ID: {run_id}
Model: {model}
