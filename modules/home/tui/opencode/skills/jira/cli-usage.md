# JIRA CLI Usage Patterns

## Critical Requirements

**⚠️ MANDATORY: `/tmp` File Pattern**

The JIRA CLI fails when passing ticket bodies directly. You **MUST** write content to `/tmp` first, then use `$(cat /tmp/file.md)`.

```bash
# ❌ WRONG - This will fail
jira issue create --body "**Description:** Long content..."

# ✅ CORRECT - Write to /tmp first
cat > /tmp/jira_ticket.md <<'EOF'
**Description:**
...
EOF

jira issue create --body "$(cat /tmp/jira_ticket.md)"
```

---

## Creating Tickets

### Basic Creation

```bash
# 1. Write ticket body to temp file
cat > /tmp/jira_ticket_description.md <<'EOF'
**Description:**
  - As a clinic staff member, I want to see draft medications separately so that I can manage them effectively.

**Scope:**
  - Patient medication tab
  - Pharmacy whiteboard

**Acceptance Criteria:**
```gherkin
Given a medication is created
  When it has not been prescribed
  Then it should have `draft` status
  And appear in the draft medications section
```
EOF

# 2. Verify content
cat /tmp/jira_ticket_description.md

# 3. Create ticket
jira issue create \
  --type "Story" \
  --project DI \
  --summary "Separate draft and prescribed medications in UI" \
  --body "$(cat /tmp/jira_ticket_description.md)"
```

### Ticket Types

Common types:
- `Story` - New features or user-facing changes
- `Task` - Technical work, chores, refactoring
- `Bug` - Defects or issues
- `Epic` - Large initiatives containing multiple stories

```bash
# Bug example
jira issue create \
  --type "Bug" \
  --project DI \
  --summary "Medication dosage not saving correctly" \
  --body "$(cat /tmp/jira_ticket.md)"
```

### Project Codes

Use the correct project code:
- `DI` - DataIntegrity project (example)
- Check `jira project list` for available projects

---

## Viewing Tickets

### Basic View

```bash
# View single ticket
jira issue view DI-1234

# View with plain output (easier to parse)
jira issue view DI-1234 --plain
```

### Extracting Information

```bash
# Get ticket status
jira issue view DI-1234 --plain | grep "Status:"

# Get epic/parent relationships
jira issue view DI-1234 --plain | grep -E "(Epic|Parent):"

# Get assignee
jira issue view DI-1234 --plain | grep "Assignee:"
```

### List Tickets

```bash
# List tickets in project
jira issue list --project DI

# List my tickets
jira issue list --assignee $(jira me)

# List by status
jira issue list --status "In Progress"
```

---

## Editing Tickets

### Update Ticket Body

```bash
# 1. Write new body to temp file
cat > /tmp/jira_ticket_update.md <<'EOF'
**Description:**
  - Updated description content...

**Scope:**
  - Updated scope...

**Acceptance Criteria:**
```gherkin
Given updated criteria...
```
EOF

# 2. Verify content
cat /tmp/jira_ticket_update.md

# 3. Update ticket
jira issue edit DI-1234 --no-input \
  --body "$(cat /tmp/jira_ticket_update.md)"
```

### Update Other Fields

```bash
# Update summary
jira issue edit DI-1234 --no-input \
  --summary "New summary text"

# Update status
jira issue edit DI-1234 --no-input \
  --status "In Progress"

# Update assignee
jira issue edit DI-1234 --no-input \
  --assignee "username"
```

---

## Adding Comments

### Basic Comment

```bash
# Simple comment
jira issue comment add DI-1234 --no-input \
  "Ticket updated to enhanced template format."
```

### Multi-line Comment

```bash
# For longer comments, use heredoc
jira issue comment add DI-1234 --no-input "$(cat <<'EOF'
Ticket updated with the following improvements:
- Enhanced description with specific actors
- Expanded acceptance criteria covering edge cases
- Added relevant dev notes with file references

Previous version preserved in ticket history.
EOF
)"
```

### Context Comments

```bash
# When splitting tickets
jira issue comment add DI-1234 --no-input \
  "Ticket scope reduced and split for better delivery. Split into: DI-5678, DI-5679. Previous version preserved in ticket history."

# When updating
jira issue comment add DI-1234 --no-input \
  "Updated to template standards. All original requirements preserved. Changes: improved description format, expanded acceptance criteria. See ticket history for previous version."
```

---

## Common Workflows

### Create Ticket Workflow

```bash
# Step 1: Write ticket
cat > /tmp/jira_ticket_description.md <<'EOF'
[... ticket content ...]
EOF

# Step 2: Verify
cat /tmp/jira_ticket_description.md

# Step 3: Create
jira issue create \
  --type "Story" \
  --project DI \
  --summary "Summary under 80 chars" \
  --body "$(cat /tmp/jira_ticket_description.md)"
```

### Update Ticket Workflow

```bash
# Step 1: View current state
jira issue view DI-1234

# Step 2: Write improved version
cat > /tmp/jira_ticket_update.md <<'EOF'
[... improved content ...]
EOF

# Step 3: Verify
cat /tmp/jira_ticket_update.md

# Step 4: Update
jira issue edit DI-1234 --no-input \
  --body "$(cat /tmp/jira_ticket_update.md)"

# Step 5: Add explanation comment
jira issue comment add DI-1234 --no-input \
  "Ticket updated to enhanced format. Previous version in history."

# Step 6: Verify update
jira issue view DI-1234
```

### Split Ticket Workflow

```bash
# Step 1: Update original with reduced scope
cat > /tmp/jira_original_update.md <<'EOF'
[... reduced scope content ...]
EOF

jira issue edit DI-1234 --no-input \
  --body "$(cat /tmp/jira_original_update.md)"

# Step 2: Create first split ticket
cat > /tmp/jira_split1.md <<'EOF'
[... first split content ...]
EOF

NEW_TICKET_1=$(jira issue create \
  --type "Story" \
  --project DI \
  --summary "[Split from DI-1234] Feature 1 summary" \
  --body "$(cat /tmp/jira_split1.md)" \
  --plain | grep -oP 'DI-\d+')

echo "Created: $NEW_TICKET_1"

# Step 3: Create second split ticket
cat > /tmp/jira_split2.md <<'EOF'
[... second split content ...]
EOF

NEW_TICKET_2=$(jira issue create \
  --type "Story" \
  --project DI \
  --summary "[Split from DI-1234] Feature 2 summary" \
  --body "$(cat /tmp/jira_split2.md)" \
  --plain | grep -oP 'DI-\d+')

echo "Created: $NEW_TICKET_2"

# Step 4: Link tickets (see linking.md)
# Step 5: Add comments explaining split (see linking.md)
```

---

## Troubleshooting

### Body Content Not Appearing
**Symptom:** Ticket created but body is empty or truncated

**Solution:** Use `/tmp` file pattern, never pass content directly:
```bash
# Write to file first
cat > /tmp/jira_ticket.md <<'EOF'
[content]
EOF

# Then reference with cat
--body "$(cat /tmp/jira_ticket.md)"
```

### Heredoc Quoting Issues
**Symptom:** Variables expanded or special characters causing errors

**Solution:** Use single quotes in heredoc delimiter:
```bash
# Correct - prevents variable expansion
cat > /tmp/file.md <<'EOF'
Content with $variables and `backticks`
EOF

# Wrong - will expand variables
cat > /tmp/file.md <<EOF
Content with $variables and `backticks`
EOF
```

### Command Not Found
**Symptom:** `jira: command not found`

**Solution:** Ensure JIRA CLI is installed and in PATH:
```bash
# Check if installed
which jira

# Install if needed (varies by system)
```

### Permission Errors
**Symptom:** Cannot create/edit tickets

**Solution:** Verify authentication:
```bash
# Test authentication
jira me

# Re-authenticate if needed
jira init
```
