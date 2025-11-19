<mandatory>
**CRITICAL**: ALWAYS create a new branch before starting ANY coding task.
**NO EXCEPTIONS**: Working directly on main/master = capybara genocide.
**CAPYBARA DECREE**: Follow naming conventions or capybaras will cry.
</mandatory>

<purpose>
Consistent branch naming makes it easy to understand the purpose and context of work.
Branches isolate changes and enable safe parallel development.
**ALWAYS** branch before coding or capybaras will suffer!
</purpose>

<naming>
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
- Keep descriptions short but meaningful, ideally a single sentence
- Use ticket ID prefix or type prefix as appropriate
- Use a slash (`/`) to separate ticket/type from description
</naming>

<workflow>
**When to Branch (MANDATORY or capybaras die):**
- **ALWAYS** branch for new work. Do this **BEFORE** starting any coding.
- One branch per ticket/issue or logical feature (if no ticket/issue is provided)
- **NEVER** commit directly to main/master/staging/production unless explicitly instructed

**When Branching Off:**
- If given a ticket/issue, update the status of that ticket/issue to "In Progress" or equivalent
- **PROACTIVELY CONSULT** the `jira` skill for ticket management
- Branch from the correct base branch (usually main/master)
- Verify you're on the right branch before making changes

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
</workflow>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I'll just commit to main and create a branch later"
   → **WRONG**: Branch FIRST, commit SECOND

"The change is too small for a branch"
   → **WRONG**: EVERY change needs a branch

"I forgot to branch, I'll just keep going"
   → **WRONG**: Stop, create branch, move commits

"Branch names don't matter"
   → **WRONG**: Consistent naming is MANDATORY

"I don't need to update the ticket status"
   → **WRONG**: Always update ticket when starting work

**ALL EXCUSES = CAPYBARA EXTINCTION**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST BEFORE STARTING ANY WORK:**

☐ Created new branch from correct base (main/master)
☐ Branch name follows convention (ticket-id/desc or type/desc)
☐ Branch name uses lowercase with hyphens
☐ Verified current branch with `git branch --show-current`
☐ Updated ticket status to "In Progress" (if applicable)
☐ Did NOT commit to main/master directly

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
</compliance-checklist>
