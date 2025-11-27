---
name: jira
description: MANDATORY for ANY JIRA-related tasks - provides comprehensive JIRA workflows including ticket creation, CLI usage, linking patterns, and research workflows. Consult this skill PROACTIVELY before creating, reviewing, or working with JIRA tickets.
---

<mandatory>
**MANDATORY**: ALWAYS consult this skill before ANY JIRA operation.
**CRITICAL**: ALWAYS read `template.md` FIRST when creating/reviewing tickets.
**NO EXCEPTIONS**: Skipping proper structure = wasted time and poor ticket quality.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context. DO NOT spawn additional subagents from this skill. JIRA operations are typically PRIMARY AGENT skills. Return to primary agent with recommendations instead.
</subagent-context>

<structure>
This skill provides JIRA knowledge across focused files:

- **`template.md`** - SINGLE SOURCE OF TRUTH for ticket structure, sections, examples, compliance
- **`cli-usage.md`** - JIRA CLI patterns, ticket operations, linking workflows
- **`research.md`** - Codebase and ticket research workflows for finding context

**Reference these files based on your task:**
- Creating/reviewing tickets → Read `template.md`
- Using JIRA CLI or linking tickets → Read `cli-usage.md`
- Finding context/patterns → Read `research.md`
</structure>

<quick-reference>
**Creating Tickets:**
1. **ALWAYS** read `template.md` FIRST (NO EXCEPTIONS)
2. Research existing context if needed (`research.md`)
3. Use CLI patterns correctly (`cli-usage.md`)
4. Link related tickets appropriately (`cli-usage.md`)

**Reviewing Tickets:**
1. **ALWAYS** consult `template.md` for standards
2. Research related tickets/code if needed (`research.md`)
3. Update using CLI patterns (`cli-usage.md`)
4. Maintain/add links (`cli-usage.md`)

**Working with JIRA:**
- All CLI operations → `cli-usage.md`
- Linking tickets → `cli-usage.md`
- Finding code patterns → `research.md`
</quick-reference>

<anti-rationalization>
**THESE EXCUSES NEVER APPLY**

"I know the ticket format already"
**WRONG**: Read template.md anyway for current standards

"This is a simple ticket"
**WRONG**: Even simple tickets need proper structure

"User gave me complete requirements"
**WRONG**: Requirements are WHAT, template is HOW

**NO EXCEPTIONS**
</anti-rationalization>
