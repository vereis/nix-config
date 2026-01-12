---
description: Create a pull request for the current branch
argument-hint: [base-branch]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch --show-current), Bash(git symbolic-ref:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh repo view:*)
---

## Context

- Branch: !`git branch --show-current`
- Status: !`git status`
- Diff: !`git diff`
- Recent commits: !`git log --oneline -10`

## Task

Create a pull request for the current branch.

Rules:

- Determine base branch:
  - If `$1` is set, use it.
  - Otherwise detect base branch via `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`.
- Generate a concise PR title and body.
- If the branch is not pushed, push with upstream tracking.
- Use `gh pr create`.
- Return the PR URL.
