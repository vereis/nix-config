---
name: git-workflow
description: MANDATORY for creating branches, commits, or pull requests. Defines commit message formats, branching conventions, and PR best practices. ALWAYS consult this skill before ANY mutating git operation. OTHERWISE CAPYBARAS WILL DIE.
---

<mandatory>
**CRITICAL**: ALWAYS consult this skill before ANY git operation (branch, commit, PR).
**NO EXCEPTIONS**: Skipping this skill = broken workflow = capybara extinction.
**CAPYBARA DECREE**: Use quality-check/commit/pr subagents, NEVER run git commands directly.
</mandatory>

<core-principles>
- **Atomic commits** - Each commit represents a single logical change
- **Clear messages** - Commit messages explain purpose, not implementation
- **Consistent format** - Use standardized prefixes and structure
- **Test before commit** - All commits MUST pass tests
- **Lint before commit** - All commits MUST pass linting
- **Subagent delegation** - ALWAYS use quality-check/commit/pr subagents
</core-principles>

<structure>
This skill provides comprehensive git workflow knowledge:

- **`commits.md`** - Commit message formats, rules, workflow, and anti-rationalization
- **`branching.md`** - Branch naming conventions, creation workflow, and enforcement
- **`pr-practices.md`** - Pull request creation, quality checks, and templates

**PROACTIVELY** consult these files BEFORE any git operation or capybaras will go extinct!
</structure>

<proactive-triggers>
**ALWAYS use this skill when:**
- Creating a new branch
- Making any commit
- Creating a pull request
- User mentions git operations
- Starting any coding task (need to branch first!)

**Don't wait for "use git-workflow" - BE PROACTIVE or capybaras will be disappointed!**
</proactive-triggers>

<workflow-summary>
**Quick Reference (MANDATORY):**

**Before ANY coding:**
1. Consult `branching.md` - Create appropriately named branch
2. Update ticket status to "In Progress" (if applicable)

**Before EVERY commit:**
1. Consult `commits.md` - Understand format and workflow
2. Run quality-check subagent (tests)
3. Run quality-check subagent (lint)
4. Use commit subagent (NEVER git commit directly)

**Before creating PR:**
1. Consult `pr-practices.md` - Understand requirements
2. Run ALL quality checks via ci-discovery skill
3. Verify all commits follow format
4. Use pr subagent (NEVER gh pr create directly)
</workflow-summary>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I know the git workflow, I don't need to consult the skill"
   → **WRONG**: ALWAYS consult to ensure compliance

"This is a quick fix, I'll skip the quality checks"
   → **WRONG**: EVERY commit needs tests/lint

"I can run git commands faster directly"
   → **WRONG**: Subagents are MANDATORY

"The branch name doesn't matter"
   → **WRONG**: Consistent naming is REQUIRED

"I'll clean up commits later"
   → **WRONG**: Make clean commits from the start

**ALL EXCUSES = CAPYBARA DEATH**
**NO EXCEPTIONS EVER**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST FOR ANY GIT OPERATION:**

☐ Consulted relevant git-workflow file (branching/commits/pr-practices)
☐ Created branch with correct naming (if starting work)
☐ Ran quality-check subagent for tests (if committing)
☐ Ran quality-check subagent for lint (if committing)
☐ Used commit subagent (if committing)
☐ Used pr subagent (if creating PR)
☐ Did NOT run git/gh commands directly
☐ Followed atomic workflow pattern

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
</compliance-checklist>
