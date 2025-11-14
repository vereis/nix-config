# JIRA Ticket Linking

## When to Link Tickets

Link tickets when there are **clear relationships** between them:
- One ticket blocks another
- Tickets are related but independent
- Ticket is part of an epic
- Ticket was split from another
- Tickets are duplicates

**Ask permission first** if relationship is unclear: "Should I link this to DI-1234 as [relationship type]?"

---

## Relationship Types

### Common Relationships

| Type | Description | Example Use Case |
|------|-------------|------------------|
| `Blocks` | First ticket must complete before second | Authentication must be built before user settings |
| `Relates` | General relationship, no dependency | Two features in same area |
| `Duplicate` | Tickets describe same work | Accidentally created twice |
| `Epic-Story` | Story belongs to Epic | Feature is part of larger initiative |
| `Work item split` | Ticket was split into smaller parts | Large ticket broken into deliverable pieces |

### When to Use Each Type

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

---

## Linking Syntax

### Basic Link Command

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

### Fallback Pattern

Some relationship types may not be available in all JIRA instances:

```bash
# Try specific type first, fallback to "Relates"
jira issue link DI-1234 DI-5678 "Work item split" || jira issue link DI-1234 DI-5678 "Relates"
```

---

## Linking Workflows

### Creating Ticket with Links

```bash
# 1. Create ticket
cat > /tmp/jira_ticket.md <<'EOF'
**Description:**
...
EOF

jira issue create \
  --type "Story" \
  --project DI \
  --summary "Implement medication draft status" \
  --body "$(cat /tmp/jira_ticket.md)"

# 2. Link to related tickets
jira issue link DI-1234 DI-5678 "Relates"

# 3. Link to epic (if applicable)
jira issue link DI-100 DI-1234 "Epic-Story"
```

### Linking When Splitting Tickets

When splitting one ticket into multiple:

```bash
# 1. Update original ticket with reduced scope
cat > /tmp/jira_original_update.md <<'EOF'
...reduced scope...
EOF

jira issue edit DI-1234 --no-input \
  --body "$(cat /tmp/jira_original_update.md)"

# 2. Create split tickets
cat > /tmp/jira_split1.md <<'EOF'
...first split...
EOF

NEW_TICKET_1=$(jira issue create \
  --type "Story" \
  --project DI \
  --summary "[Split from DI-1234] Feature 1" \
  --body "$(cat /tmp/jira_split1.md)" \
  --plain | grep -oP 'DI-\d+')

cat > /tmp/jira_split2.md <<'EOF'
...second split...
EOF

NEW_TICKET_2=$(jira issue create \
  --type "Story" \
  --project DI \
  --summary "[Split from DI-1234] Feature 2" \
  --body "$(cat /tmp/jira_split2.md)" \
  --plain | grep -oP 'DI-\d+')

# 3. Link splits to original
jira issue link $NEW_TICKET_1 DI-1234 "Work item split" || jira issue link $NEW_TICKET_1 DI-1234 "Relates"
jira issue link $NEW_TICKET_2 DI-1234 "Work item split" || jira issue link $NEW_TICKET_2 DI-1234 "Relates"

# 4. If epic exists, link splits to same epic
EPIC_KEY=$(jira issue view DI-1234 --plain | grep "Epic:" | awk '{print $2}')
if [ -n "$EPIC_KEY" ]; then
  jira issue link $EPIC_KEY $NEW_TICKET_1 "Epic-Story"
  jira issue link $EPIC_KEY $NEW_TICKET_2 "Epic-Story"
fi

# 5. If there are dependencies between splits
# Example: NEW_TICKET_2 blocks NEW_TICKET_1
jira issue link $NEW_TICKET_2 $NEW_TICKET_1 "Blocks"

# 6. Add comments to ALL tickets explaining relationships
jira issue comment add DI-1234 --no-input \
  "Ticket scope reduced and split for better delivery. Split into: $NEW_TICKET_1, $NEW_TICKET_2. Previous version preserved in ticket history."

jira issue comment add $NEW_TICKET_1 --no-input \
  "Split from DI-1234 for better scope management. Related split tickets: $NEW_TICKET_2"

jira issue comment add $NEW_TICKET_2 --no-input \
  "Split from DI-1234 for better scope management. Related split tickets: $NEW_TICKET_1. This work blocks $NEW_TICKET_1."
```

### Linking Dependencies

When one ticket blocks another:

```bash
# DI-5678 must complete before DI-1234 can start
# IMPORTANT: Blocker comes FIRST in command
jira issue link DI-5678 DI-1234 "Blocks"

# Add explanatory comments
jira issue comment add DI-1234 --no-input \
  "⚠️ Blocked by DI-5678 - authentication must be implemented first"

jira issue comment add DI-5678 --no-input \
  "⚠️ Blocks DI-1234 - user settings depend on this work"
```

---

## Adding Comments When Linking

### Standard Comment Patterns

**For splits:**
```bash
# On original ticket
jira issue comment add DI-1234 --no-input \
  "Ticket split into: DI-5678 (UI changes), DI-5679 (API changes). See those tickets for detailed scope."

# On split tickets
jira issue comment add DI-5678 --no-input \
  "Split from DI-1234. Sibling ticket: DI-5679"
```

**For dependencies:**
```bash
# On blocked ticket
jira issue comment add DI-1234 --no-input \
  "⚠️ Blocked by DI-5678 - cannot start until authentication is complete"

# On blocking ticket
jira issue comment add DI-5678 --no-input \
  "⚠️ Blocks DI-1234 - complete this before starting user settings work"
```

**For related work:**
```bash
jira issue comment add DI-1234 --no-input \
  "Related to DI-5678 - both improve medication workflow. Can be developed independently."
```

---

## Verifying Links

### Check Links After Creation

```bash
# View ticket to see links section
jira issue view DI-1234

# Look for "Links:" section in output
# Should show:
# - Blocks: DI-5678
# - Relates to: DI-9999
# - etc.
```

### Manual Verification

After linking, **always verify in JIRA web UI**:
1. Open ticket in browser: `https://vetspireapp.atlassian.net/browse/DI-1234`
2. Check "Links" section on right side
3. Verify all relationships appear correctly
4. Confirm comments explaining links are present

---

## Common Linking Scenarios

### Scenario 1: Creating Feature Set

Multiple related features that can be developed independently:

```bash
# Create all tickets
TICKET_1=$(jira issue create --type Story --project DI --summary "Add medication search" --body "$(cat /tmp/t1.md)" --plain | grep -oP 'DI-\d+')
TICKET_2=$(jira issue create --type Story --project DI --summary "Add medication filters" --body "$(cat /tmp/t2.md)" --plain | grep -oP 'DI-\d+')
TICKET_3=$(jira issue create --type Story --project DI --summary "Add medication export" --body "$(cat /tmp/t3.md)" --plain | grep -oP 'DI-\d+')

# Link them as related (no dependencies)
jira issue link $TICKET_1 $TICKET_2 "Relates"
jira issue link $TICKET_1 $TICKET_3 "Relates"
jira issue link $TICKET_2 $TICKET_3 "Relates"

# Link to epic
jira issue link DI-100 $TICKET_1 "Epic-Story"
jira issue link DI-100 $TICKET_2 "Epic-Story"
jira issue link DI-100 $TICKET_3 "Epic-Story"
```

### Scenario 2: Sequential Work

Features that must be built in order:

```bash
# Create tickets
TICKET_1=$(jira issue create --type Story --project DI --summary "Add user authentication" --body "$(cat /tmp/t1.md)" --plain | grep -oP 'DI-\d+')
TICKET_2=$(jira issue create --type Story --project DI --summary "Add user profile" --body "$(cat /tmp/t2.md)" --plain | grep -oP 'DI-\d+')
TICKET_3=$(jira issue create --type Story --project DI --summary "Add user settings" --body "$(cat /tmp/t3.md)" --plain | grep -oP 'DI-\d+')

# Link dependencies (authentication -> profile -> settings)
jira issue link $TICKET_1 $TICKET_2 "Blocks"
jira issue link $TICKET_2 $TICKET_3 "Blocks"

# Add dependency comments
jira issue comment add $TICKET_2 --no-input "⚠️ Blocked by $TICKET_1 - requires authentication"
jira issue comment add $TICKET_3 --no-input "⚠️ Blocked by $TICKET_2 - requires user profile"
```

### Scenario 3: Duplicate Detection

Found duplicate ticket:

```bash
# Link as duplicate
jira issue link DI-1234 DI-5678 "Duplicate"

# Add comment to duplicate
jira issue comment add DI-5678 --no-input \
  "Duplicate of DI-1234. Closing this ticket in favor of the original."

# Close the duplicate
jira issue edit DI-5678 --no-input --status "Done"
```

---

## Best Practices

1. **Always add comments** when linking - explain WHY tickets are linked
2. **Verify in web UI** - CLI output can be misleading, check browser
3. **Link during creation** when relationships are obvious
4. **Ask permission first** when relationships are unclear
5. **Use blocking sparingly** - only when there's a real technical dependency
6. **Maintain epic links** - when splitting tickets, preserve epic relationships
7. **Document splits clearly** - comments on ALL split tickets with full context
