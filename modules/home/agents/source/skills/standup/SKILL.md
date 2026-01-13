---
name: standup
description: Generate a daily standup update in Markdown using git, GitHub (gh), and Jira (best-effort).
allowed-tools:
  - Bash(date:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(gh api:*)
  - Bash(gh pr status:*)
  - Bash(gh pr list:*)
  - Bash(gh issue list:*)
  - Bash(jira issue list:*)
user-invocable: true
---

# Standup generator

Generate a daily standup update in **Markdown**.

## Time window
- Default: **since yesterday**.
- If the user provides a time window in natural language (e.g. "2 days ago"), interpret it as a `date -d` expression and use it consistently across git/GitHub/Jira.

## Inputs / assumptions
- Assume `gh` is configured.
- Assume `jira` is configured unless we see an error.

## Context collection (best effort)

### Git (local)
- `git log --since=<window> --no-merges --date=iso --pretty=format:"- %ad %s <%h>"`
- `git status --porcelain`

### GitHub
Collect in the time window:

- PRs opened by the user
- PRs merged by the user
- PR reviews done by the user (APPROVED / CHANGES_REQUESTED / COMMENTED)
- Review comments (inline review comments)
- PR conversation comments (issue comments on PRs)

Preferred sources:
- Opened/merged PRs: `gh search prs ...` (simple and stable)
- Review activity: GitHub GraphQL `contributionsCollection(from,to)`

### Jira (best effort)
Prefer **only tickets assigned to the current user**.

Collect Jira activity in the time window:
- assigned issues created in the window
- assigned issues with status changed by the user
- assigned issues updated by the user (proxy for comment activity if comment-specific queries are unavailable)

Use JQL and keep results small.

## Output format (Markdown)

- `## Yesterday`
- `## Today`
- `## Blockers`
- `## PRs Opened`
- `## PRs Merged`
- `## PR Reviews` (include approvals / change requests / notable review comments)
- `## Jira`
- `## Links` (PRs/tickets)

## Rules
- Keep it short: ~12 bullets total unless the user asks otherwise.
- Prefer outcomes over raw command dumps.
- Never invent tickets/PRs or blockers.
- If a source is unavailable (Jira not configured), note it once and continue.
