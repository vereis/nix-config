---
description: Review and update existing JIRA tickets
agent: build
---

Review and update an existing JIRA ticket:

1. Load the jira skill to understand ticket structure standards
2. Parse ticket identifier (handle multiple formats like pr:review):
   - **URL**: Extract ticket ID from URL
   - **Ticket ID/Key**: Use directly (e.g., DI-1234)
   - **Search term**: Use `jira issue list` to find matching ticket
3. Fetch ticket details:
   ```bash
   jira issue view TICKET-ID --plain
   ```
4. Safety check - warn user if ticket status is "In Progress" or "In Review":
   ```bash
   jira issue view TICKET-ID --plain | grep "Status:"
   ```
5. Analyze ticket against template.md standards:
   - Are actors specific (not generic "user")?
   - Are benefits observable and testable?
   - Does scope define WHERE (pages/URLs), not HOW (code)?
   - Are acceptance criteria in Gherkin format?
   - Are happy path, edge cases, and error scenarios covered?
   - Are dev notes high-level only (if present)?
6. Draft improvements (preserve all original information):
   - Transform to match template structure
   - Enhance sections that need improvement
   - Maintain original intent and requirements
7. Show current vs proposed changes in clear preview format:
   ```
   Current Description:
   [Original text]
   
   Proposed Description:
   [Improved text]
   
   Analysis:
   - Enhanced actor specificity
   - Added observable benefits
   - Expanded acceptance criteria
   ```
8. Get explicit approval: "Approve these changes? (yes/no)"
9. Update ticket using jira CLI (follow cli-usage.md patterns):
   ```bash
   # Create .opencode/tickets directory if needed
   mkdir -p .opencode/tickets
   
   # Write updated content to local file
   cat > .opencode/tickets/TICKET-ID.md <<'EOF'
   [Updated content]
   EOF
   
   # Verify content
   cat .opencode/tickets/TICKET-ID.md
   
   # Update ticket
   jira issue edit TICKET-ID --no-input \
     --body "$(cat .opencode/tickets/TICKET-ID.md)"
   ```
10. Add comment explaining changes:
    ```bash
    jira issue comment add TICKET-ID --no-input \
      "Ticket updated to enhanced template format."
    ```
11. Verify updates:
    ```bash
    jira issue view TICKET-ID
    ```

**Safety Rules:**
- **Preserve information** - Never lose original content
- **Check status** - Warn before modifying in-progress tickets
- **Get approval** - Show complete preview before updating
- **Add comments** - Always explain what changed and why
- **One ticket at a time** - Process sequentially
