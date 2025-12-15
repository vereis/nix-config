# Pull Request Best Practices

## Mandatory

**MANDATORY**: ALWAYS run quality checks BEFORE creating PR.
**CRITICAL**: Use `/code:pr`, NEVER create PRs directly with gh pr create.
**NO EXCEPTIONS**: Creating PR with failing tests/lints = broken CI and wasted time.

## Workflow

Follow these best practices **EXACTLY** when creating PRs to ensure highest quality and easiest review:

**1. Run quality checks** to ensure all tests/lints pass before creating PR
- Use `discovery` skill to find and run all relevant commands on project. Read `$HOME/.config/opencode/skills/discovery/ci.md` for CI command discovery
- **NEVER** skip `discovery` skill - you WILL miss important commands leading to broken PRs/CI
- **ALWAYS** run:
  - All tests (use `/code:check`)
  - All linters (use `/code:check`)
- **FAIL FAST** if any checks fail - fix issues before creating PR
- **MANDATORY**: If any tests/linters fail, you MUST fix issues before PR creation

**2. Verify commits** in branch you're creating PR from
- All commits follow format from `commits.md`
- Each commit represents atomic change
- Commit messages are clear and descriptive
- No WIP or temporary commits

**3. Create clear PR title** matching commit format
- E.g., `[TICKET-123] High level summary of changes`
- E.g., `[FEAT] High level summary of changes`
- Refer to commits or `commits.md` for examples

**4. Write detailed PR description** focusing on WHY changes were made
- **MANDATORY**: Use template for project you're working on (if exists)
  - Use `discovery` skill to check for PR templates
  - If no template, review recent merged PRs for style/format
  - Otherwise keep it clear and concise, follow `backup-template` below
- **NEVER** use overly formal/robotic LLM-generated language
  - No phrases like "Adds comprehensive ..." or the like
  - If in doubt, keep it simple and casual
- Focus on **WHY** changes were made, not just what was changed
- **Concise** - 1-3 bullet points per section
- **Context** - Explain why, not what (code shows what)
- **Links** - Always link to related tickets/issues
- **Testing** - Show the change works
- **Breaking changes** - Call out clearly if present

**5. Create PR**
- **ALWAYS** use `/code:pr` to create PR
- **ALWAYS** use `jira` skill to update ticket status after PR creation (if applicable)
- **ALWAYS** summarize what you did with link to PR, link to ticket, and any other relevant context

## Backup Template

If no project-specific template exists, use this:

```markdown
## Summary
- Brief explanation of what problem this solves
- Why these changes were needed
- Any important context or background

## Changes
- High-level overview of approach taken
- Major technical decisions made

## Testing
- How this was tested
- Any edge cases covered

## Related
- Links to tickets/issues
- Links to related PRs
- References to documentation
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY:**

"I'll create PR and fix tests in follow-up commits"
**WRONG**: PR must pass ALL checks BEFORE creation

"CI will catch any issues"
**WRONG**: Run checks LOCALLY first

"I don't need to use /code:pr"
**WRONG**: /code:pr is MANDATORY

"I'll write PR description later"
**WRONG**: Write description WHEN creating PR

"My commits are self-explanatory, no description needed"
**WRONG**: PR description is MANDATORY

**NO EXCEPTIONS**

## Compliance Checklist

**MANDATORY - Before creating PR:**

☐ Used discovery skill to find quality check commands
☐ Ran /code:check for ALL tests
☐ ALL tests PASSED (fixed if failed)
☐ Ran /code:check for ALL linters
☐ ALL linters PASSED (fixed if failed)
☐ Verified all commits follow format from commits.md
☐ Each commit is atomic (one semantic change)
☐ No WIP or temporary commits
☐ PR title follows commit message format
☐ PR description explains WHY (not just what)
☐ Used /code:pr (NOT gh pr create directly)
☐ Updated ticket status (if applicable)

**IF ANY UNCHECKED THEN PR WILL FAIL**
