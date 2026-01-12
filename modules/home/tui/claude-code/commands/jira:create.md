---
description: Create a JIRA ticket with guided workflow
argument-hint: [ticket-summary]
allowed-tools: Bash(jira:*), Bash(mkdir:*), Bash(mv:*), Bash(cat:*), Bash(grep:*), Bash(head:*)
---

Create a JIRA ticket with proper structure.

**User request:** $ARGUMENTS

1. Load the jira skill to understand ticket structure
2. If no input provided, ask the user what ticket to create
3. Draft ticket:
   - Outcomes over implementation
   - Specific actors
   - Acceptance criteria in Given/When/Then
4. Present draft to user and iterate
5. Get explicit confirmation: "Ready to create? (yes/no)"
6. Create ticket using jira CLI, saving a local copy under `.opencode/tickets/`:

- Ensure directory exists: !`mkdir -p .opencode/tickets`

When creating, capture the ticket ID from the CLI output and rename the draft file to match.
Return ticket URL and local path.
