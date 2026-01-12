# JIRA CLI Usage Patterns

**MANDATORY**: Follow these workflows for JIRA CLI operations.

## Critical CLI Quirks

The `jira` CLI requires specific patterns to avoid failures:

| Operation | Correct Pattern |
|-----------|----------------|
| Multi-line content | Write to `/tmp` first, use `$(cat /tmp/file.md)` |
| Creating tickets | Use `--no-input` flag |
| Viewing tickets | Can use `--plain` flag for easier parsing |
| Creating/editing | **NO** `--plain` flag (doesn't exist) |

**Example:**
```bash
# WRONG - Multi-line content directly fails
jira issue create --body "**Description:** Long content..."

# CORRECT - Write to /tmp first
cat > /tmp/jira_ticket.md <<'EOF'
**Description:**
...
EOF
jira issue create --body "$(cat /tmp/jira_ticket.md)"
```

## Creating Tickets

**Always reference template.md FIRST, then:**

```bash
# 1. Write ticket body to /tmp
cat > /tmp/jira_ticket.md <<'EOF'
[Ticket content following template.md]
EOF

# 2. Create ticket
jira issue create --no-input \
  --type Story \
  --project DI \
  --summary "Title of the ticket" \
  --body "$(cat /tmp/jira_ticket.md)"

# 3. Capture ticket ID for linking
TICKET_ID=$(jira issue create --no-input \
  --type Story \
  --project DI \
  --summary "Title" \
  --body "$(cat /tmp/file.md)" 2>&1 | grep -oP 'DI-\d+' | head -1)
```

## Viewing Tickets

```bash
# View single ticket
jira issue view DI-1234

# View with plain output (easier parsing)
jira issue view DI-1234 --plain

# Get specific information
jira issue view DI-1234 --plain | grep "Status:"
jira issue view DI-1234 --plain | grep -E "(Epic|Parent):"

# List tickets
jira issue list --project DI
jira issue list --status "In Progress"
```

## Editing Tickets

**Always write to /tmp first and verify:**

```bash
# 1. View current ticket
jira issue view DI-1234

# 2. Write updated content to /tmp
cat > /tmp/jira_update.md <<'EOF'
Updated content...
EOF

# 3. Verify content
cat /tmp/jira_update.md

# 4. Update ticket
jira issue edit DI-1234 --no-input \
  --body "$(cat /tmp/jira_update.md)" \
  --summary "New title" \
  --status "In Progress"
```

## Adding Comments

**Always use --no-input:**

```bash
# Simple comment
jira issue comment add DI-1234 --no-input \
  "Ticket updated to enhanced template format."

# Longer comment
jira issue comment add DI-1234 --no-input "$(cat <<'EOF'
Ticket updated with improvements:
- Enhanced description with specific actors
- Expanded acceptance criteria
- Added relevant dev notes
EOF
)"
```

## Linking Tickets

### Relationship Types

| Type | Use Case | Example |
|------|----------|---------|
| `Blocks` | First must complete before second | Auth before user settings |
| `Relates` | General relationship, no dependency | Related features in same area |
| `Duplicate` | Same work in multiple tickets | Accidentally created twice |
| `Epic-Story` | Story belongs to Epic | Feature part of larger initiative |
| `Work item split` | Ticket split into smaller parts | Large ticket broken down |

### Link Syntax

```bash
# Syntax: jira issue link [TICKET_1] [TICKET_2] "[RELATIONSHIP]"

# General relationship
jira issue link DI-1234 DI-5678 "Relates"

# Blocker (BLOCKER comes FIRST)
jira issue link DI-1234 DI-5678 "Blocks"
# Meaning: DI-1234 blocks DI-5678

# Epic to story
jira issue link DI-100 DI-1234 "Epic-Story"

# Work item split
jira issue link DI-1234 DI-5678 "Work item split"

# Fallback if relationship type unavailable
jira issue link DI-1234 DI-5678 "Work item split" || jira issue link DI-1234 DI-5678 "Relates"
```

**Note:** Link command does **NOT** use `--type` flag!

### Linking Workflow

**Always follow:**
1. Link to related tickets
2. Link to epic (if applicable)
3. Add comments explaining relationships
4. Verify links with `jira issue view TICKET-ID`

## Splitting Tickets

**Mandatory workflow:**

```bash
# 1. Update original ticket with reduced scope
cat > /tmp/reduced_scope.md <<'EOF'
[Reduced scope content]
EOF
jira issue edit DI-1234 --no-input --body "$(cat /tmp/reduced_scope.md)"

# 2. Create split tickets
SPLIT_1=$(jira issue create --no-input \
  --type Story --project DI \
  --summary "Feature A from DI-1234" \
  --body "$(cat /tmp/split_1.md)" 2>&1 | grep -oP 'DI-\d+' | head -1)

SPLIT_2=$(jira issue create --no-input \
  --type Story --project DI \
  --summary "Feature B from DI-1234" \
  --body "$(cat /tmp/split_2.md)" 2>&1 | grep -oP 'DI-\d+' | head -1)

# 3. Link splits to original
jira issue link DI-1234 $SPLIT_1 "Work item split"
jira issue link DI-1234 $SPLIT_2 "Work item split"

# 4. If dependencies exist
jira issue link $SPLIT_1 $SPLIT_2 "Blocks"

# 5. Add explanatory comments
jira issue comment add DI-1234 --no-input \
  "Ticket scope reduced and split into: $SPLIT_1, $SPLIT_2."

jira issue comment add $SPLIT_1 --no-input \
  "Split from DI-1234. Related split: $SPLIT_2"

# 6. Verify
jira issue view DI-1234
jira issue view $SPLIT_1
```

## Common Patterns

**Feature set (no dependencies):**
```bash
# Create and link as related
T1=$(jira issue create ... | grep -oP 'DI-\d+' | head -1)
T2=$(jira issue create ... | grep -oP 'DI-\d+' | head -1)
jira issue link $T1 $T2 "Relates"
jira issue link DI-100 $T1 "Epic-Story"
jira issue comment add $T1 --no-input "Part of feature set with $T2"
```

**Sequential work (dependencies):**
```bash
# Create and establish blocking relationships
T1=$(jira issue create --summary "Add authentication" ... | grep -oP 'DI-\d+' | head -1)
T2=$(jira issue create --summary "Add user profile" ... | grep -oP 'DI-\d+' | head -1)
jira issue link $T1 $T2 "Blocks"
jira issue comment add $T2 --no-input "⚠️ Blocked by $T1 - requires authentication"
```

## When to Link or Split

**Link when:**
- Creating feature set with multiple related features
- Sequential work where one ticket must finish first
- Duplicate tickets describing same work
- Stories belong to an epic

**Split when:**
- Original ticket too large (> 3 days estimated)
- Contains multiple independent features
- Different parts can be delivered separately
- Scope needs reduction for sprint planning
