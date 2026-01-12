---
description: Create a JIRA ticket (wrapper around skills)
argument-hint: [ticket-summary]
disable-model-invocation: true
allowed-tools: Bash(jira:*), Bash(mkdir:*), Bash(mv:*), Bash(cat:*), Bash(grep:*), Bash(head:*)
---

This is a lightweight wrapper around Skills.

Apply:
- `jira`
- `communication`

## Task

Create a JIRA ticket with proper structure.

User request: $ARGUMENTS

- If no summary is provided, ask what ticket to create.
- Draft ticket content (outcomes over implementation, clear actors, Given/When/Then acceptance criteria).
- Get explicit confirmation before creating.
- Create via `jira` CLI.
