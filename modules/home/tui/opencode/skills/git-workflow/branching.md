# Git Branching

## Mandatory

**MANDATORY**: ALWAYS create a new branch before starting ANY coding task.
**CRITICAL**: Working directly on main/master = broken workflow and conflicts.
**NO EXCEPTIONS**: Follow naming conventions for consistency.

## Purpose

Consistent branch naming makes it easy to understand the purpose and context of work.
Branches isolate changes and enable safe parallel development.
**ALWAYS** branch before coding!

## Naming Conventions

**For ticket/issue work:** `<ticket-id>/<short-description>`
**For non-ticket work:** `<type>/<short-description>`

**Examples:**
- `VS-1234/add-user-auth`
- `GH-456/fix-memory-leak`
- `PROJ-789/update-api-format`
- `feat/real-time-notifications`
- `bug/payment-processor-crash`
- `chore/update-dependencies`
- `refactor/extract-service-layer`
- `docs/api-documentation`

**Common types for non-ticket branches:**
- **feat/** - New features
- **bug/** - Bug fixes
- **chore/** - Maintenance work
- **refactor/** - Code restructuring
- **docs/** - Documentation updates
- **perf/** - Performance improvements
- **test/** - Test additions/modifications

**Guidelines:**
- Use lowercase with hyphens (kebab-case)
- Keep descriptions short but meaningful
- Use ticket ID prefix or type prefix as appropriate
- Use slash (`/`) to separate ticket/type from description

## Workflow

**When to Branch (MANDATORY):**
- **ALWAYS** branch for new work BEFORE starting any coding
- One branch per ticket/issue or logical feature
- **NEVER** commit directly to main/master/staging/production unless explicitly instructed

**When Branching Off:**
- If given ticket/issue, update status to "In Progress" or equivalent
- **PROACTIVELY CONSULT** the `jira` skill for ticket management
- Branch from correct base branch (usually main/master)
- Verify you're on right branch before making changes

**Common Commands:**
```bash
# Create and switch to new branch
git checkout -b TICKET-123/short-description

# Or for non-ticket work
git checkout -b feat/short-description

# Verify current branch
git branch --show-current

# Push branch to remote
git push -u origin TICKET-123/short-description
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY:**

"I'll just commit to main and create branch later"
**WRONG**: Branch FIRST, commit SECOND

"Change is too small for a branch"
**WRONG**: EVERY change needs a branch

"I forgot to branch, I'll keep going"
**WRONG**: Stop, create branch, move commits

"Branch names don't matter"
**WRONG**: Consistent naming is MANDATORY

"I don't need to update ticket status"
**WRONG**: Always update ticket when starting work

**NO EXCEPTIONS**

## Compliance Checklist

**MANDATORY - Before starting ANY work:**

☐ Created new branch from correct base (main/master)
☐ Branch name follows convention (ticket-id/desc or type/desc)
☐ Branch name uses lowercase with hyphens
☐ Verified current branch with `git branch --show-current`
☐ Updated ticket status to "In Progress" (if applicable)
☐ Did NOT commit to main/master directly

**IF ANY UNCHECKED THEN WORKFLOW IS BROKEN**
