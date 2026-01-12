---
description: Review a PR (wrapper around skills)
argument-hint: [pr-number-or-url]
disable-model-invocation: true
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr status:*), Bash(gh repo view:*)
---

This is a lightweight wrapper around Skills.

Apply:
- `github-pr`
- `code-review`
- `communication` (only if drafting human-facing comments)

## Context

- PR metadata: !`gh pr view $ARGUMENTS --json number,title,body,headRefName,baseRefName,files,comments,reviews,url`
- PR diff: !`gh pr diff $ARGUMENTS`
- PR checks: !`gh pr checks $ARGUMENTS || true`

## Task

Review this PR with strict quality standards.

- If the review is large/noisy, delegate analysis to the `code-reviewer` subagent and return its handoff.
- Do NOT post comments unless explicitly asked.
