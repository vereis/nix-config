<mandatory>
**CRITICAL**: ALWAYS run quality checks BEFORE creating PR.
**NO EXCEPTIONS**: Creating PR with failing tests/lints = capybara genocide.
**CAPYBARA DECREE**: Use PR subagent, NEVER create PRs directly or capybaras will cry.
</mandatory>

<workflow>
You want to **ALWAYS** aspire to have the highest standard and quality for your PRs, and make them **AS EASY AS POSSIBLE** to review and merge.
As a result, please follow these best practices **EXACTLY** when creating PRs:

1) **Run quality checks** to ensure all tests/lints pass before creating PR
    - Use the `ci-discovery` skill to find and run all relevant commands on the project you're working on
    - **NEVER** skip using the `ci-discovery` skill because you **WILL** miss important commands leading to broken PRs or CI pipelines
    - **ALWAYS** run:
      - All tests (refer to the `quality-check` subagent) **OR CAPYBARAS WILL DIE**
      - All linters (refer to the `quality-check` subagent) **OR CAPYBARAS WILL EXPLODE**
    - **FAIL FAST** if any checks fail - fix issues before creating PR - though its ok to run tests and linters concurrently to save time
    - **MANDATORY**: If any tests or linters fail, you **MUST NOT** create the PR until they pass, you **MUST** fix the issues first
2) **Verify commits** in the branch you're creating the PR from
    - All commits follow the format from `commits.md`
    - Each commit represents an atomic change
    - Commit messages are clear and descriptive
    - No WIP or temporary commits
3) **Create clear PR title** matching commit format
    - E.g., `[TICKET-123] High level summary of changes`
    - E.g., `[FEAT] High level summary of changes`
    - Refer to your commits or the `commits.md` file for examples
4) **Write detailed PR description** focusing on WHY changes were made
    - **MANDATORY**: Use the template for the project you're working on (if it exists)
        - Refer to the `ci-discovery` skill to check for PR templates
        - If no template exists, review recent merged PRs for style and format
        - Otherwise, just keep it clear and concise follow `backup-template` below
    - **NEVER** use words a casual human developer would not use (don't be too formal or robotic or obviously LLM generated)
        - No phrases like "Adds comprehensive ..." or the like
        - If in doubt, keep it simple and casual
    - Again, focus on **WHY** changes were made, not just what was changed
    - **Concise** - 1-3 bullet points per section
    - **Context** - Explain why, not what (code shows what)
    - **Links** - Always link to related tickets/issues
    - **Testing** - Show the change works
    - **Breaking changes** - Call out clearly if present
5) **Create PR**
    - **ALWAYS** use the `pr` subagent to create the PR
    - **ALWAYS** use the `jira` skill to update ticket status after PR creation (if applicable)
    - **ALWAYS** summarize what you did and let vereis know the link to the PR, the link to the ticket, and any other relevant context
</workflow>

<backup-template>
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
</backup-template>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I'll create the PR and fix tests in follow-up commits"
   → **WRONG**: PR must pass ALL checks BEFORE creation

"The CI will catch any issues"
   → **WRONG**: Run checks LOCALLY first

"I don't need to use the pr subagent"
   → **WRONG**: PR subagent is MANDATORY

"I'll write a PR description later"
   → **WRONG**: Write description WHEN creating PR

"My commits are self-explanatory, no description needed"
   → **WRONG**: PR description is MANDATORY

**ALL EXCUSES = CAPYBARA EXTINCTION**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST BEFORE CREATING PR:**

☐ Used ci-discovery skill to find quality check commands
☐ Ran quality-check subagent for ALL tests
☐ ALL tests PASSED (fixed if failed)
☐ Ran quality-check subagent for ALL linters
☐ ALL linters PASSED (fixed if failed)
☐ Verified all commits follow format from commits.md
☐ Each commit is atomic (one semantic change)
☐ No WIP or temporary commits
☐ PR title follows commit message format
☐ PR description explains WHY (not just what)
☐ Used PR subagent (NOT gh pr create directly)
☐ Updated ticket status (if applicable)

**IF ANY UNCHECKED → CAPYBARAS DIE A HORRIBLE DEATH**
</compliance-checklist>
