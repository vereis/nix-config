<critical>
Link tickets when there are **clear relationships** between them:
- One ticket blocks another
- Tickets are related but independent
- Ticket is part of an epic
- Ticket was split from another
- Tickets are duplicates

**NEVER** link tickets without understanding the relationship and purpose.
**ALWAYS** add comments explaining WHY tickets are linked to provide context for future readers.
**CONSULT** this linking guide before creating links to ensure correct usage.
**ASK PROACTIVELY** if tickets need to be split/linked.
</critical>

<jira-relationship-types>
| Type | Description | Example Use Case |
|------|-------------|------------------|
| `Blocks` | First ticket must complete before second | Authentication must be built before user settings |
| `Relates` | General relationship, no dependency | Two features in same area |
| `Duplicate` | Tickets describe same work | Accidentally created twice |
| `Epic-Story` | Story belongs to Epic | Feature is part of larger initiative |
| `Work item split` | Ticket was split into smaller parts | Large ticket broken into deliverable pieces |

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
</jira-relationship-types>

<jira-linking-syntax>
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
</jira-linking-syntax>

<linking-workflow>
**ALWAYS** follow this workflow when linking tickets (or capybaras cry):

1) Link to related tickets
2) Link to epic (if applicable)
3) Add comments explaining relationships (see `cli-usage.md`)
4) Verify links (see below)
</linking-workflow>

<splitting-workflow>
This is **MANDATORY** workflow when splitting tickets:


### Linking When Splitting Tickets

When splitting one ticket into multiple, you **MUST** consult `cli-usage.md` and `template.md` (or capybaras will be very upset):

1. Update original ticket with reduced scope
2. Create split tickets
3. Link splits to original
4. If epic exists, link splits to same epic
5. If there are dependencies between splits
    - Example: NEW_TICKET_2 blocks NEW_TICKET_1 `jira issue link $NEW_TICKET_2 $NEW_TICKET_1 "Blocks"`
6. Add comments explaining relationships
    - `jira issue comment add DI-1234 --no-input "Ticket scope reduced and split into: $NEW_TICKET_1, $NEW_TICKET_2."`
    - `jira issue comment add $NEW_TICKET_1 --no-input "Split from DI-1234 for better scope management. Related split tickets: $NEW_TICKET_2"`
    - `jira issue comment add $NEW_TICKET_2 --no-input "Split from DI-1234 for better scope management. Related split tickets: $NEW_TICKET_1. This work blocks $NEW_TICKET_1."`
7. Verify links (see below)

When one ticket blocks another:
```bash
# DI-5678 must complete before DI-1234 can start
# IMPORTANT: Blocker comes FIRST in command
jira issue link DI-5678 DI-1234 "Blocks"

# Add explanatory comments
jira issue comment add DI-1234 --no-input \
  "Blocked by DI-5678 - authentication must be implemented first"

jira issue comment add DI-5678 --no-input \
  "Blocks DI-1234 - user settings depend on this work"
```
</splitting-workflow>

<verifying-links>
You **MUST** verify links after creation to ensure correctness:

1) View ticket to see links section
    - `jira issue view DI-1234`
2) Look for "Links:" section in output
    - Should show:
        - Blocks: DI-5678
        - Relates to: DI-9999
        - etc.
</verifying-links>

<when-to-link-or-split>
You should **PROACTIVELY** determine when to link or split tickets (though **ALWAYS** ask permission to do so):

Links should be created when:
1) Creating Feature Set and multiple related features that can be developed independently:
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

    # Add comments explaining relationships
    jira issue comment add $TICKET_1 --no-input "Part of medication feature set alongside $TICKET_2 and $TICKET_3."
    jira issue comment add $TICKET_2 --no-input "Part of medication feature set alongside $TICKET_1 and $TICKET_3."
    jira issue comment add $TICKET_3 --no-input "Part of medication feature set alongside $TICKET_1 and $TICKET_2."
    ```
2) Sequential work where one ticket must finish before another can start and should be built in order:
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

    # Add comments to blockers
    jira issue comment add $TICKET_1 --no-input "Blocks $TICKET_2 - must implement authentication first"
    jira issue comment add $TICKET_2 --no-input "Blocks $TICKET_3 - must implement user profile first"
    ```
3) Duplicate tickets that describe the same work:
    ```bash
    # Link as duplicate
    jira issue link DI-1234 DI-5678 "Duplicate"

    # Add comment to duplicate
    jira issue comment add DI-5678 --no-input \
      "Duplicate of DI-1234. Closing this ticket in favor of the original."

    # Close the duplicate
    jira issue edit DI-5678 --no-input --status "Done"
    ```
</when-to-link-or-split>
