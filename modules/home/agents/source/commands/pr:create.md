---
description: Create a pull request (wrapper around skills)
argument-hint: [base-branch]
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git symbolic-ref:*), Bash(git push:*), Bash(gh pr create:*), Bash(gh repo view:*)
---

This is a lightweight wrapper around Skills.

Apply:
- `github-pr`
- `communication`
- `git` (Conventional Commits + clean history expectations)

## Context

- Branch: !`git branch --show-current`
- Base branch (remote default): !`git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true`
- Status: !`git status`
- Diff: !`git diff`
- Recent commits: !`git log --oneline -10`

## Task

Create a PR for the current branch.

Rules:
- Determine base branch:
  - If `$1` is set, use it.
  - Otherwise, infer from the remote default branch shown above.
- Ensure the branch is pushed (ask if unsure).
- Draft a concise PR title/body (follow `communication`).
- Create the PR with `gh pr create`.
- Return the PR URL.
