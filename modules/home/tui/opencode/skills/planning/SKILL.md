---
name: planning
description: MANDATORY when given JIRA tickets, GitHub issues, or asked to pick up ANY task. Provides comprehensive planning workflows including requirement analysis, backend-first ordering, atomic workflow patterns, and task breakdown frameworks. Use PROACTIVELY - don't wait to be asked!
license: MIT
---

# Planning Skill

**CRITICAL**: Use this skill PROACTIVELY whenever you receive:
- JIRA ticket numbers (e.g., "Work on PROJ-123", "Pick up VS-456")
- GitHub issue references (e.g., "Fix issue #456", "Implement #789")
- Ad-hoc task requests (e.g., "Add user settings feature", "Refactor the auth module")
- Complex feature requests
- Refactoring tasks

This skill helps you analyze requirements and break down work into actionable implementation steps.

## Core Philosophy

- **Backend-first ordering** - Build from data layer up to UI
- **Atomic workflow** - Each semantic change followed by test → lint → commit
- **TodoWrite for planning** - ALL steps captured before starting work
- **Delegate to subagents** - Never run test/lint/commit commands directly

## Structure

This skill provides comprehensive task planning knowledge:

- **`backend-first.md`** - Backend-first task ordering with rationale
- **`atomic-workflow.md`** - Test/lint/commit cycle per semantic change
- **`breakdown-process.md`** - How to analyze requirements and create task lists
- **`examples.md`** - Good vs bad task breakdowns with explanations

## Quick Reference

### Planning a New Task
1. Gather context (ticket details, codebase patterns)
2. Analyze requirements and acceptance criteria
3. Identify dependencies and blockers
4. Break down using backend-first ordering
5. Add atomic workflow steps (test/lint/commit) after EACH implementation task
6. Create TodoWrite list BEFORE starting work

### Task Ordering
1. Database/Schema changes
2. Model/Type definitions
3. Business logic implementation
4. API/Interface layer
5. Frontend/UI changes (last)

### After Each Implementation Step
- [ ] Run test subagent (NEVER directly!)
- [ ] Run lint subagent (NEVER directly!)
- [ ] Run commit subagent (if tests/lint pass)

This catches issues immediately instead of at the end when everything's broken!

## When to Use (PROACTIVELY!)

**Always use this skill when:**
- User mentions a ticket number (JIRA, GitHub, Linear, etc.)
- User says "pick up", "work on", "implement", "fix", "add"
- User describes a feature or task to build
- Planning any non-trivial work (more than a 1-line fix)

**Don't wait for explicit "plan this" instruction - BE PROACTIVE!**
