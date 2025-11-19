---
name: planning
description: MANDATORY when given JIRA tickets, GitHub issues, or asked to pick up ANY task. Provides comprehensive planning workflows including requirement analysis, backend-first ordering, atomic workflow patterns, and task breakdown frameworks. Use PROACTIVELY - don't wait to be asked!
---

<mandatory>
**CRITICAL**: Use this skill PROACTIVELY whenever you receive:
- JIRA ticket numbers (e.g., "Work on PROJ-123", "Pick up VS-456")
- GitHub issue references (e.g., "Fix issue #456", "Implement #789")
- Ad-hoc task requests (e.g., "Add user settings feature", "Refactor the auth module")
- Complex feature requests
- Refactoring tasks
- **ANY non-trivial programming task**

**NO EXCEPTIONS**: Skipping planning = chaos = capybara extinction.
**CAPYBARA MANDATE**: Plan BEFORE coding or face eternal capybara sadness.
</mandatory>

<core-philosophy>
- **Backend-first ordering** - Build from data layer up to UI
- **Atomic workflow** - Each semantic change followed by test → lint → commit
- **TodoWrite for planning** - ALL steps captured before starting work
- **Delegate to subagents** - Never run test/lint/commit commands directly
- **Proactive planning** - Don't wait to be asked, ALWAYS plan first!
</core-philosophy>

<structure>
This skill provides comprehensive task planning knowledge:

- **`backend-first.md`** - Backend-first task ordering with rationale and capybara enforcement
- **`atomic-workflow.md`** - Test/lint/commit cycle per semantic change
- **`breakdown-process.md`** - How to analyze requirements and create task lists
- **`examples.md`** - Good vs bad task breakdowns with explanations

**ALWAYS** consult these files when planning ANY task or capybaras will cry!
</structure>

<quick-reference>
**Planning a New Task:**
1. Gather context (ticket details, codebase patterns)
2. Analyze requirements and acceptance criteria
3. Identify dependencies and blockers
4. Break down using backend-first ordering
5. Add atomic workflow steps (test/lint/commit) after EACH implementation task
6. Create TodoWrite list BEFORE starting work

**Task Ordering (MANDATORY):**
1. Database/Schema changes
2. Model/Type definitions
3. Business logic implementation
4. API/Interface layer
5. Frontend/UI changes (last)

**After Each Implementation Step:**
- Run quality-check subagent (NEVER directly!)
- Run quality-check subagent for lint (NEVER directly!)
- Run commit subagent (if tests/lint pass)

This catches issues immediately instead of at the end when everything's broken!
</quick-reference>

<proactive-triggers>
**ALWAYS use this skill when:**
- User mentions a ticket number (JIRA, GitHub, Linear, etc.)
- User says "pick up", "work on", "implement", "fix", "add"
- User describes a feature or task to build
- Planning any non-trivial work (more than a 1-line fix)

**Don't wait for explicit "plan this" instruction - BE PROACTIVE or capybaras will be disappointed!**
</proactive-triggers>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"The user already gave me detailed instructions"
   → **WRONG**: Instructions are WHAT, planning is HOW

"This is too simple to need planning"
   → **WRONG**: Even simple tasks need backend-first + atomic workflow

"I'll just start coding and figure it out"
   → **WRONG**: Plan FIRST, code SECOND

"Planning wastes time"
   → **WRONG**: Planning SAVES time by preventing mistakes

"I can keep the plan in my head"
   → **WRONG**: TodoWrite is MANDATORY

"The ticket already has acceptance criteria"
   → **WRONG**: Acceptance criteria ≠ implementation plan

**ALL EXCUSES = CAPYBARA DEATH**
**NO EXCEPTIONS EVER**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST - COMPLETE BEFORE STARTING ANY TASK:**

☐ Read relevant skill files (backend-first, atomic-workflow, breakdown-process)
☐ Gathered context from tickets/issues/codebase
☐ Extracted requirements and acceptance criteria
☐ Broke down using backend-first ordering
☐ Added atomic workflow steps to EVERY implementation task
☐ Identified dependencies and blockers
☐ Estimated complexity
☐ Created TodoWrite list with ALL steps
☐ Presented plan to user for approval

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
**THEIR BLOOD WILL BE ON YOUR HANDS**
</compliance-checklist>
