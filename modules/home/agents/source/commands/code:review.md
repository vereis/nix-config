---
description: Code review wrapper (prefer skill auto-trigger)
argument-hint: [scope]
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git symbolic-ref:*), Bash(git branch:*), Read, Grep, Glob
---

This is a lightweight wrapper around Skills.

Apply:
- `code-review`
- `git` (for clean history guidance)

Requested scope (optional): `$ARGUMENTS`

## Context

- Branch: !`git branch --show-current`
- Base branch (remote default): !`git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true`
- Status: !`git status`
- Diff (working tree): !`git diff`
- Diff vs base (best-effort): !`git diff origin/master...HEAD 2>/dev/null || git diff origin/main...HEAD 2>/dev/null || true`

## Task

Review the context above with strict quality standards.

- If the review is large/noisy, delegate to the `code-reviewer` subagent and return its handoff.
