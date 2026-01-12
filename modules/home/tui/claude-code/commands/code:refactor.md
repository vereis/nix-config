---
description: Analyze code for refactoring opportunities (read-only)
context: fork
agent: refactorer
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read, Grep, Glob
---

## Context

- Status: !`git status`
- Diff (staged+unstaged): !`git diff HEAD`
- Recent commits: !`git log --oneline -10`

## Task

Based on the diff above, propose refactoring opportunities.

Constraints:

- No code modifications.
- No further command execution beyond the provided context.

Output:

- High priority
- Medium priority
- Low priority
- Patterns observed to respect
