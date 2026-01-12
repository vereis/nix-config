---
name: github-pr
description: Create, review, and update GitHub pull requests using gh + git with our quality standards. Use when the user mentions PRs, pull requests, GitHub reviews, or asks to open/review a PR.
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git push:*)
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
  - Bash(gh pr checks:*)
  - Bash(gh pr create:*)
  - Bash(gh repo view:*)
user-invocable: true
---

# GitHub PR workflow

## Non-negotiables
- Code quality is sacred.
- Commit history is part of the deliverable. Keep it clean.
- Treat warnings seriously.

## When creating a PR
1. Gather context:
   - `git status`, `git diff`, `git log --oneline`
2. Ensure branch is pushed (ask before pushing if uncertain).
3. Draft title/body following the `communication` skill.
4. Create PR with `gh pr create`.
5. Return the PR URL.

## When reviewing a PR
1. Gather context:
   - `gh pr view` (title/body/base/head)
   - `gh pr diff`
   - `gh pr checks`
2. Apply `code-review` standards (and/or delegate analysis to the `code-reviewer` subagent for a structured handoff).
3. Summarize:
   - top risks
   - must-fix vs should-fix
   - test gaps
4. Do not post comments unless explicitly asked.

## Review output style
- If asked to draft comments, follow the `communication` skill.
