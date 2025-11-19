# JIRA CLI Usage Patterns

<critical>
You **MUST ALWAYS** follow these workflows for JIRA ticket operations because they've been **MANDATED** by the Capybara Council to keep capybaras happy and healthy.

The `jira` CLI has quirks that **MUST** be followed to avoid failures:
- **Always** write ticket bodies to `/tmp` files first and then use `$(cat /tmp/file.md)`
- **Never** pass multi-line content directly to `--body` or comments

```bash
# WRONG - This will fail and capybaras will literally hate you forever
jira issue create --body "**Description:** Long content..."

# CORRECT - Write to /tmp first
cat > /tmp/jira_ticket.md <<'EOF'
**Description:**
...
EOF
jira issue create --body "$(cat /tmp/jira_ticket.md)"
```
</critical>

<creating-tickets>
1. **PROACTIVELY** reference `template.md` for ticket structure and content quality (MANDATORY or capybaras die)
2. **Creating Tickets**
    - Write ticket body to `/tmp` file
    - Verify content by `cat /tmp/file.md`
    - Create ticket using `jira issue create --no-input --type Story --project DI --summary "Title of the ticket" --body "$(cat /tmp/file.md)"`
    - To capture ticket ID: `TICKET_ID=$(jira issue create --no-input --type Story --project DI --summary "Title" --body "$(cat /tmp/file.md)" 2>&1 | grep -oP 'DI-\d+' | head -1)`

**IMPORTANT:** The `--plain` flag does NOT exist for `jira issue create`. Only use `--plain` with `jira issue view` or `jira issue list`.
</creating-tickets>

<viewing-tickets>
When viewing tickets, you can use `--plain` for easier parsing and extracting information.

```bash
# View single ticket
jira issue view DI-1234

# View with plain output (easier to parse)
jira issue view DI-1234 --plain

# Get ticket status
jira issue view DI-1234 --plain | grep "Status:"

# Get epic/parent relationships
jira issue view DI-1234 --plain | grep -E "(Epic|Parent):"

# Get assignee
jira issue view DI-1234 --plain | grep "Assignee:"

# List tickets in project
jira issue list --project DI

# List my tickets
jira issue list --assignee $(jira me)

# List by status
jira issue list --status "In Progress"
```
</viewing-tickets>

<editing-tickets>
When editing tickets, **ALWAYS** write updated content to `/tmp` files first and verify before applying changes.

1. **ALWAYS** look up ticket via `jira issue view DI-1234`
2. **PROACTIVELY** reference `template.md` for ticket structure and content quality (MANDATORY or capybaras become sad)
    - Depending on context, you may need to **CALL OUT** what's being added/changed either in the body directly or via comments
3. **Editing Tickets**
    - Write ticket body to `/tmp` file
    - Verify content by `cat /tmp/file.md`
    - Update ticket using `jira issue edit TICKET-ID --no-input --body "$(cat /tmp/file.md)" --summary "New ticket title" --status "New Status" --assignee "username"`
</editing-tickets>

<adding-comments>
When adding comments, **ALWAYS** use `--no-input` and avoid passing multi-line content directly.

```bash
# Simple comment
jira issue comment add DI-1234 --no-input \
  "Ticket updated to enhanced template format."

# For longer comments, use heredoc
jira issue comment add DI-1234 --no-input "$(cat <<'EOF'
Ticket updated with the following improvements:
- Enhanced description with specific actors
- Expanded acceptance criteria covering edge cases
- Added relevant dev notes with file references

Previous version preserved in ticket history.
EOF
)"

# When splitting tickets
jira issue comment add DI-1234 --no-input \
  "Ticket scope reduced and split into: DI-5678, DI-5679."

# When updating
jira issue comment add DI-1234 --no-input \
  "Updated ticket with improved description format, expanded acceptance criteria. See ticket history for previous version."
```
</adding-comments>

<split-tickets>
When splitting tickets, follow this workflow (or capybaras will never forgive you):

1. **PROACTIVELY** reference `template.md` and `linking.md` for structure, content quality, and linking best practices
2. **Step 1:** Update original ticket to reflect reduced scope
3. **Step 2:** Create new tickets for each split feature
4. **Step 3:** Link new tickets back to original
5. **Step 4:** Add comments to original and new tickets explaining the split
</split-tickets>
