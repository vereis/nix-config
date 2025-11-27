# JIRA CLI Usage and Linking Patterns

<mandatory>
**MANDATORY**: Follow these workflows for JIRA ticket operations.
**CRITICAL**: Always write ticket bodies to `/tmp` files first, then use `$(cat /tmp/file.md)`.
**NO EXCEPTIONS**: The `jira` CLI has quirks that MUST be followed to avoid failures.
</mandatory>

## Critical CLI Quirks

The `jira` CLI requires specific patterns:

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

**Important flags:**
- `--plain` flag **ONLY** works with `jira issue view` and `jira issue list`
- `--plain` flag **DOES NOT EXIST** for `jira issue create`
- Always use `--no-input` to avoid interactive prompts

## Creating Tickets

**1. Reference template.md FIRST** (MANDATORY)

**2. Write ticket body to /tmp file**

**3. Create ticket:**
```bash
# Basic creation
jira issue create --no-input \
  --type Story \
  --project DI \
  --summary "Title of the ticket" \
  --body "$(cat /tmp/jira_ticket.md)"

# Capture ticket ID for linking
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
jira issue view DI-1234 --plain | grep "Assignee:"

# List tickets
jira issue list --project DI
jira issue list --assignee $(jira me)
jira issue list --status "In Progress"
```

## Editing Tickets

**Always write updated content to /tmp first and verify:**

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
  --status "In Progress" \
  --assignee "username"
```

## Adding Comments

**Always use --no-input:**

```bash
# Simple comment
jira issue comment add DI-1234 --no-input \
  "Ticket updated to enhanced template format."

# Longer comment with heredoc
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
```

## Ticket Linking

<linking-relationships>
**Relationship Types:**

| Type | Description | Example Use Case |
|------|-------------|------------------|
| `Blocks` | First ticket must complete before second | Authentication must be built before user settings |
| `Relates` | General relationship, no dependency | Two features in same area |
| `Duplicate` | Tickets describe same work | Accidentally created twice |
| `Epic-Story` | Story belongs to Epic | Feature is part of larger initiative |
| `Work item split` | Ticket was split into smaller parts | Large ticket broken into deliverable pieces |

**When to use each:**

**Blocks:**
- Clear dependency where one must finish first
- Technical prerequisite exists
- Work cannot proceed without completion

**Relates:**
- Work in same area but independent
- Good to know about but no dependency
- Similar features or related improvements

**Duplicate:**
- Same work described in multiple tickets
- Mark one as duplicate, close it

**Epic-Story:**
- Story is part of larger epic
- Epic groups related stories

**Work item split:**
- Original ticket was too large
- Split into smaller deliverable pieces
- Maintains history and context
</linking-relationships>

<linking-syntax>
**CLI Syntax:**

```bash
# IMPORTANT: Order matters for "Blocks"!
# Syntax: jira issue link [TICKET_1] [TICKET_2] "[RELATIONSHIP]"

# General relationship
jira issue link DI-1234 DI-5678 "Relates"

# Blocker relationship (BLOCKER comes FIRST)
jira issue link DI-1234 DI-5678 "Blocks"
# Meaning: DI-1234 blocks DI-5678

# Duplicate
jira issue link DI-1234 DI-5678 "Duplicate"

# Epic to story
jira issue link DI-100 DI-1234 "Epic-Story"
# DI-100 is the epic, DI-1234 is the story

# Work item split
jira issue link DI-1234 DI-5678 "Work item split"
```

**NOTE:** The link command does **NOT** use `--type` flag!

**Fallback pattern** if relationship type not available:
```bash
jira issue link DI-1234 DI-5678 "Work item split" || jira issue link DI-1234 DI-5678 "Relates"
```
</linking-syntax>

<linking-workflow>
**ALWAYS follow this workflow when linking:**

1. Link to related tickets
2. Link to epic (if applicable)
3. Add comments explaining relationships
4. Verify links

**Verifying links:**
```bash
# View ticket to see links section
jira issue view DI-1234

# Look for "Links:" section showing:
# - Blocks: DI-5678
# - Relates to: DI-9999
```
</linking-workflow>

## Splitting Tickets

**Mandatory workflow when splitting:**

1. **Reference template.md and this file for structure and linking**
2. Update original ticket with reduced scope
3. Create new tickets for each split feature
4. Link new tickets back to original
5. Add comments explaining the split

**Example split workflow:**
```bash
# 1. Update original ticket
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

# 4. If dependencies exist between splits
jira issue link $SPLIT_1 $SPLIT_2 "Blocks"
# $SPLIT_1 must complete before $SPLIT_2

# 5. Add explanatory comments
jira issue comment add DI-1234 --no-input \
  "Ticket scope reduced and split into: $SPLIT_1, $SPLIT_2."

jira issue comment add $SPLIT_1 --no-input \
  "Split from DI-1234. Related split: $SPLIT_2"

jira issue comment add $SPLIT_2 --no-input \
  "Split from DI-1234. Related split: $SPLIT_1. Blocked by $SPLIT_1."

# 6. Verify links
jira issue view DI-1234
jira issue view $SPLIT_1
jira issue view $SPLIT_2
```

## Common Linking Patterns

**Feature Set (no dependencies):**
```bash
# Create all tickets
T1=$(jira issue create ... | grep -oP 'DI-\d+' | head -1)
T2=$(jira issue create ... | grep -oP 'DI-\d+' | head -1)
T3=$(jira issue create ... | grep -oP 'DI-\d+' | head -1)

# Link them as related
jira issue link $T1 $T2 "Relates"
jira issue link $T1 $T3 "Relates"
jira issue link $T2 $T3 "Relates"

# Link to epic
jira issue link DI-100 $T1 "Epic-Story"
jira issue link DI-100 $T2 "Epic-Story"
jira issue link DI-100 $T3 "Epic-Story"

# Add comments
jira issue comment add $T1 --no-input "Part of feature set with $T2, $T3"
jira issue comment add $T2 --no-input "Part of feature set with $T1, $T3"
jira issue comment add $T3 --no-input "Part of feature set with $T1, $T2"
```

**Sequential work (dependencies):**
```bash
# Create tickets
T1=$(jira issue create --summary "Add authentication" ... | grep -oP 'DI-\d+' | head -1)
T2=$(jira issue create --summary "Add user profile" ... | grep -oP 'DI-\d+' | head -1)
T3=$(jira issue create --summary "Add settings" ... | grep -oP 'DI-\d+' | head -1)

# Link dependencies (auth → profile → settings)
jira issue link $T1 $T2 "Blocks"
jira issue link $T2 $T3 "Blocks"

# Add dependency comments
jira issue comment add $T2 --no-input "⚠️ Blocked by $T1 - requires authentication"
jira issue comment add $T3 --no-input "⚠️ Blocked by $T2 - requires user profile"
jira issue comment add $T1 --no-input "Blocks $T2 - must implement auth first"
jira issue comment add $T2 --no-input "Blocks $T3 - must implement profile first"
```

**Duplicate tickets:**
```bash
# Link as duplicate
jira issue link DI-1234 DI-5678 "Duplicate"

# Add comment to duplicate
jira issue comment add DI-5678 --no-input \
  "Duplicate of DI-1234. Closing in favor of original."

# Close the duplicate
jira issue edit DI-5678 --no-input --status "Done"
```

## When to Link or Split

**PROACTIVELY determine when to link/split (always ask permission first):**

**Link when:**
- Creating feature set with multiple related features that can be developed independently
- Sequential work where one ticket must finish before another
- Duplicate tickets describing same work
- Stories belong to an epic

**Split when:**
- Original ticket is too large (> 3 days estimated)
- Ticket contains multiple independent features
- Different parts can be delivered separately
- Scope needs to be reduced for sprint planning
