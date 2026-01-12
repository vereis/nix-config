---
description: Review and update an existing JIRA ticket
argument-hint: [ticket-key-or-url]
allowed-tools: Bash(jira:*), Bash(grep:*), Bash(mkdir:*), Bash(cat:*), Bash(mv:*)
---

Review and update an existing JIRA ticket.

**Ticket identifier:** $ARGUMENTS

1. Load the jira skill
2. Fetch ticket details: !`jira issue view $ARGUMENTS --plain`
3. Warn if ticket status is in-progress/review (do not edit without confirmation)
4. Draft improvements while preserving all original information
5. Show current vs proposed body
6. Get explicit approval before editing
7. If approved, update via `jira issue edit` and add a comment explaining the changes
