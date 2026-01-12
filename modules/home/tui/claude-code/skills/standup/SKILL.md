---
name: standup
description: Generate a daily standup update in Markdown from git activity and optional gh/jira context.
allowed-tools:
  - Bash(date:*)
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(gh pr status:*)
  - Bash(gh pr list:*)
  - Bash(gh issue list:*)
  - Bash(jira issue list:*)
  - Bash(jira issue view:*)
user-invocable: true
---

# Standup generator

Generate a daily standup update in **Markdown**.

## Inputs
- If the user provides a time window (e.g. "since Friday", "last 2 days"), use it.
- Otherwise default to: **since yesterday**.

## Context collection (best effort)
Use Bash to gather:

- Git commits:
  - `git log --since="yesterday" --no-merges --date=iso --pretty=format:"- %ad %s (%an) <%h>"`
- WIP/uncommitted:
  - `git status --porcelain`

Optional enrichers (do not fail if unavailable):
- GitHub (if `gh` works):
  - `gh pr status`
  - `gh pr list -L 10 --author @me --state open`
- Jira (if configured):
  - a small list of issues assigned to the user / recently updated (keep it short)

## Output format (Markdown)

- `## Yesterday`
  - Summarize meaningful outcomes inferred from commits (group related commits).
- `## Today`
  - Next steps inferred from WIP + recent activity.
- `## Blockers`
  - If none, write: `- None`
- `## Links` (only if you found any)
  - PRs/issues/tickets with short titles.

## Rules
- Keep it short: ~12 bullets total unless the user asks otherwise.
- Prefer outcomes over raw commit dumps.
- If there are zero commits since the window start, say so and lean on WIP for Today.
- Never invent ticket IDs, PRs, or blockers.
