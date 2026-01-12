---
description: Review your local changes for issues (read-only)
context: fork
agent: code-reviewer
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read, Grep, Glob
---

## Context

- Status: !`git status`
- Diff (staged+unstaged): !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Task

Analyze the diff above.

Constraints:

- Do not run Bash beyond the provided context collection.
- Do not edit or write files.

Output:

- Critical issues
- Warnings
- Suggestions
