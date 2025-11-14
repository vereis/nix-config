---
name: jira
description: STRONGLY RECOMMENDED for ANY JIRA-related tasks. Comprehensive ticket management knowledge including templates, CLI usage patterns, research workflows, and quality standards. Consult this skill before creating, reviewing, or working with JIRA tickets.
license: MIT
---

# JIRA Skill

**IMPORTANT**: Whenever you're working with JIRA tickets (creating, reviewing, updating, or researching), you should **ALWAYS** consult this skill first.

## Core Principles

- **Outcomes over implementation** - Describe what changes, not how
- **Specific actors** - Use real roles from codebase, not "user"
- **Scope = WHERE** - Pages/components affected, not implementation details
- **Acceptance = DONE** - Observable inputs/outputs, including edge cases and errors
- **One concern per ticket** - Split complex requests into multiple tickets
- **Always review** - Show draft before creating

## Structure

This skill provides comprehensive JIRA knowledge across focused files:

- **`template.md`** - Standard ticket template structure with examples
- **`guidance.md`** - Detailed guidance for each ticket section (Description, Scope, Acceptance Criteria, Dev Notes, Questions)
- **`cli-usage.md`** - JIRA CLI patterns, workarounds, and command examples
- **`research.md`** - How to gather context from existing tickets, code, and PRs
- **`linking.md`** - Ticket relationship types, linking syntax, and best practices

## Quick Reference

### Creating Tickets
1. Research existing context if needed (`research.md`)
2. Follow template structure (`template.md`)
3. Apply section guidance (`guidance.md`)
4. Use CLI patterns correctly (`cli-usage.md`)
5. Link related tickets appropriately (`linking.md`)

### Reviewing Tickets
1. Analyze against template standards (`template.md`)
2. Check each section quality (`guidance.md`)
3. Research related tickets/code (`research.md`)
4. Update using CLI patterns (`cli-usage.md`)
5. Maintain/add links (`linking.md`)

## Usage in Commands

Commands should **ALWAYS** reference this skill and specify which files to consult:

```markdown
**MANDATORY**: Consult the jira skill before proceeding.
- Review `template.md` for ticket structure
- Follow guidance in `guidance.md` for each section
- Use patterns from `cli-usage.md` for all JIRA CLI operations
- Apply research workflow from `research.md` when gathering context
- Reference `linking.md` for ticket relationships
```

Load specific files as needed for detailed guidance and examples.
