---
description: Propose refactoring steps for local changes or a specific scope
argument-hint: [scope]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git symbolic-ref:*), Bash(git branch:*), Read, Grep, Glob
---

## Scope

Requested scope (optional): `$ARGUMENTS`

Interpretation guidance:
- If scope is empty: analyze local changes (working tree + this branch).
- If scope contains `file:line` or a filepath: focus there and related code.
- If scope says "this entire branch": analyze changes vs the default base branch.

## Context

- Branch: !`git branch --show-current`
- Status: !`git status`

### Uncommitted / local changes

- Diff (working tree): !`git diff`

### Branch changes (committed)

- Base branch: !`git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true`
- Commits vs base: !`git log --oneline origin/master..HEAD 2>/dev/null || git log --oneline --max-count=20`
- Diff vs base: !`git diff origin/master...HEAD 2>/dev/null || true`

## Task

Use the `refactorer` subagent to propose staged refactor steps.

Return a concise handoff report for the primary agent.
