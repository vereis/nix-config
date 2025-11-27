---
name: git-workflow
description: MANDATORY for creating branches, commits, or pull requests - defines commit message formats, branching conventions, and PR best practices. ALWAYS consult this skill before ANY mutating git operation.
---

<mandatory>
**MANDATORY**: ALWAYS consult this skill before ANY git operation (branch, commit, PR).
**CRITICAL**: Use quality-check/commit/pr subagents, NEVER run git commands directly.
**NO EXCEPTIONS**: Skipping this skill = broken workflow = wasted time and broken CI.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context. DO NOT spawn additional subagents from this skill. Follow the git workflow process and return results to the primary agent who will handle any necessary subagent delegation.
</subagent-context>

<core-principles>
1. **Atomic commits** - Each commit represents single logical change
2. **Clear messages** - Commit messages explain purpose, not implementation
3. **Consistent format** - Use standardized prefixes and structure
4. **Test before commit** - All commits MUST pass tests
5. **Lint before commit** - All commits MUST pass linting
6. **Subagent delegation** - ALWAYS use quality-check/commit/pr subagents
</core-principles>

<structure>
This skill provides git workflow knowledge across focused files:

- **`branching.md`** - Branch naming conventions, creation workflow
- **`commits.md`** - Commit message formats, rules, workflow
- **`pr-practices.md`** - Pull request creation, quality checks, templates

**Reference these files based on your task:**
- Starting work → Read `branching.md`
- Making commits → Read `commits.md`
- Creating PRs → Read `pr-practices.md`
</structure>

<workflow-summary>
**Quick Reference:**

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
**THESE EXCUSES NEVER APPLY**

"I know the git workflow, don't need to consult the skill"
**WRONG**: ALWAYS consult to ensure compliance

"This is a quick fix, I'll skip quality checks"
**WRONG**: EVERY commit needs tests/lint

"I can run git commands faster directly"
**WRONG**: Subagents are MANDATORY

"Branch name doesn't matter"
**WRONG**: Consistent naming is REQUIRED

"I'll clean up commits later"
**WRONG**: Make clean commits from the start

**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST:**

☐ Consulted relevant git-workflow file (branching/commits/pr-practices)
☐ Created branch with correct naming (if starting work)
☐ Ran quality-check subagent for tests (if committing)
☐ Ran quality-check subagent for lint (if committing)
☐ Used commit subagent (if committing)
☐ Used pr subagent (if creating PR)
☐ Did NOT run git/gh commands directly
☐ Followed atomic workflow pattern

**IF ANY UNCHECKED THEN EVERYTHING FAILS**
</compliance-checklist>
