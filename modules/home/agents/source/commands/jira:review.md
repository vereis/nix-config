---
description: Review/update a JIRA ticket (wrapper around skills)
argument-hint: [ticket-key-or-url]
disable-model-invocation: true
allowed-tools: Bash(jira:*), Bash(grep:*), Bash(mkdir:*), Bash(cat:*), Bash(mv:*)
---

This is a lightweight wrapper around Skills.

Apply:
- `jira`
- `communication`

## Task

Review and (optionally) update the JIRA ticket: $ARGUMENTS

- Fetch ticket details.
- Preserve original info.
- Show current vs proposed changes.
- Get explicit approval before editing.
