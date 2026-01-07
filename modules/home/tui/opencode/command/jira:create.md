---
description: Create a JIRA ticket with guided workflow
agent: general
---

Create a JIRA ticket with proper structure:

1. Load the jira skill to understand ticket structure
2. Parse user input to understand what ticket to create
3. Research context (conditional - only if user references existing tickets/PRs/code):
   - If ticket ID mentioned: `jira issue view TICKET-ID`
   - If PR mentioned: `gh pr view PR-NUMBER --json title,body,files`
   - If code mentioned: Read relevant files
4. Draft ticket following template.md structure:
   - **Description**: Specific actors (search codebase for roles), observable benefits
   - **Scope**: WHERE (pages/components with URLs), not HOW
   - **Acceptance Criteria**: Gherkin format (Given/When/Then), cover happy path, edge cases, errors
   - **Dev Notes** (optional): High-level pointers only
   - **Questions** (optional): Only blocking unknowns, tag specific people
5. Present draft to user and iterate on feedback
6. Get explicit confirmation: "Ready to create? (yes/no)"
7. Create ticket using jira CLI (follow cli-usage.md patterns):
   ```bash
   # Write ticket body to /tmp first (MANDATORY)
   cat > /tmp/jira_ticket.md <<'EOF'
   [Ticket content]
   EOF
   
   # Create ticket
   jira issue create --no-input \
     --type Story \
     --project DI \
     --summary "Title" \
     --body "$(cat /tmp/jira_ticket.md)"
   ```
8. Return ticket URL

**Principles:**
- **Outcomes over implementation** - Describe what changes, not how
- **Specific actors** - Use real roles from codebase (not generic "user")
- **One ticket at a time** - Process sequentially, clear context between tickets
- **Always review** - Show draft before creating
- **Mandatory /tmp pattern** - JIRA CLI requires file-based input for multi-line content
