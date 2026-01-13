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
1. Ensure we are on a properly named branch (see `git` + `git-workflow` skills).
2. Gather context:
   - `git status`, `git diff`, `git log --oneline`
3. Ensure branch is pushed (ask before pushing if uncertain).
4. PR title must follow Conventional Commit format: `<type>(<scope>): <desc>`.
5. PR description must be minimal and human:
   - Check for a PR template under `.github/` (if it exists, fill it).
   - Otherwise use short bullets and short sentences.
   - Mention key design decisions and any plan changes.
   - Link ticket if available.
6. Draft title/body following the `communication` skill.
7. Create PR with `gh pr create`.
8. Return the PR URL.

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
