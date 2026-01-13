---
name: jira
description: "**MANDATORY**: Load for JIRA operations. Covers ticket structure, JIRA CLI usage, and workflow patterns"
---

# JIRA Operations

**MANDATORY**: Consult this skill before ANY JIRA operation.

## When to Load

Load this skill when:
- Creating JIRA tickets
- Reviewing or updating existing tickets
- Using JIRA CLI commands
- Linking tickets or managing relationships
- Researching ticket context

## Skill Structure

This skill provides JIRA knowledge across focused files:

- **`template.md`** - Ticket structure, sections, examples, compliance checklist
- **`cli-usage.md`** - JIRA CLI patterns, ticket operations, linking workflows

**Reference based on task:**
- Creating/reviewing tickets → Read `template.md` FIRST
- CLI operations or linking → Read `cli-usage.md`

## Core Principles

### Ticket Structure
- **Outcomes over implementation**: Describe business value, not technical steps
- **Specific actors**: Use concrete roles (not generic "users" or "system")
- **Gherkin format**: Acceptance criteria use Given/When/Then
- **Scope definition**: Clear boundaries between in-scope and out-of-scope
- **Questions preserved**: Document unknowns and assumptions

### Workflow Essentials

**Creating tickets:**
1. **ALWAYS** read `template.md` first (NO EXCEPTIONS)
2. Research existing context if user references code/tickets/PRs
3. Draft ticket following template structure
4. Review with user and iterate
5. Get explicit confirmation before creating
6. Use JIRA CLI patterns from `cli-usage.md`

**Reviewing tickets:**
1. **ALWAYS** consult `template.md` for standards
2. Fetch ticket with `jira issue view TICKET-ID`
3. Check ticket status (warn if "In Progress" or "In Review")
4. Analyze against template requirements
5. Draft improvements (preserve all original info)
6. Show current vs proposed changes
7. Get explicit approval before updating
8. Update using CLI patterns from `cli-usage.md`
9. Add comment explaining changes

**Safety checks:**
- Warn before modifying in-progress tickets
- Always preserve original information
- Get explicit approval for changes
- Verify updates after applying

## Critical Warnings

**NEVER skip template.md when creating tickets**
- Even "simple" tickets need proper structure
- Requirements are WHAT, template is HOW
- Consistent structure improves team efficiency

**NEVER modify tickets without approval**
- Show preview of changes first
- Get explicit user confirmation
- Add explanatory comments when updating

**NEVER use JIRA CLI without understanding quirks**
- CLI requires `/tmp` file pattern for creation/updates
- See `cli-usage.md` for correct patterns
- Test commands are idempotent when possible
