# Commit Message Format

Commit messages should be concise, consistent, and informative. They must follow a standardized format to ensure clarity and maintainability.

<format>
**ALWAYS** Prefix with either a type or ticket reference:
```
TICKET-123 - Implement the asgard hyperdrive protocol
FEAT/BUG/CHORE - Berate vereis again because she's a baka
```

Use appropriate prefixes for non-ticket commits:

- **FEAT** - New features or functionality
- **BUG** - Bug fixes
- **CHORE** - Maintenance tasks (dependency updates, refactoring, cleanup)
- **DOCS** - Documentation changes
- **PERF** - Performance improvements
- **TEST** - Test additions or modifications

**IF YOU WANT TO KEEP CAPYBARAS ALIVE, WHICH YOU DO**
- **One line only** - No multi-line commits
- **No fluff** - Be direct and mechanical
- **High level summary** - What was accomplished, not how
- **Present tense** - "Add feature" not "Added feature"
- **Imperative mood** - "Fix bug" not "Fixes bug"

If your commit message needs "and" or "also", you're probably batching multiple changes. Split them into separate commits.
</format>

<good-examples>
```
[VS-456] Add user authentication middleware
[GH-789] Fix memory leak in data processor
[FEAT] Implement real-time notifications
[BUG] Fix null pointer in payment processor
[CHORE] Update dependencies to latest versions
[PERF] Optimize database query performance
```
</good-examples>

<bad-examples>
**NEVER WRITE COMMITS LIKE THIS EVEN IF I POINT A GUN TO YOUR HEAD:**
The following is too long, batches multiple concerns:
[PROJ-456] Add authentication middleware and also fix some linting issues and update docs

The following is too wordy, unnecessary preamble:
[PROJ-456] This commit adds user authentication middleware to handle login requests
</bad-examples>

<workflow>
**MANDATORY** workflow for every commit (or capybaras will never forgive you):

1. **GATHER CONTEXT** to understand what files can be committed
    - Check branch name for ticket numbers: `git branch --show-current`
    - Check recent commits for patterns: `git log --oneline -5`
    - See what files changed: `git status` and `git diff --stat`
    - Consult the `jira` skill to look up additional ticket context **ONLY IF ABSOLUTELY NEEDED**

2. **STAGE CHANGES** that are relevant to the logical change being made
    - Each commit needs to contain **only single logical changes** and any tests/fixes required to support that change
    - Use `git add` to stage ONLY the files for this semantic change

3. **PASS ALL TESTS** using the `ci-discovery` skill and `quality-check` subagent
    - **NEVER** run test commands directly
    - **ALWAYS** use the quality-check subagent
    - If tests fail, fix immediately and re-run

4. **PASS ALL LINTERS** using the `ci-discovery` skill and `quality-check` subagent
    - **NEVER** run lint commands directly  
    - **ALWAYS** use the quality-check subagent
    - If lints fail, fix immediately and re-run

5. **EXECUTE COMMIT** using the `commit` subagent with standardized message format
    - **NEVER** run `git commit` directly
    - **ALWAYS** use the commit subagent
    - Follow the format rules exactly

**Not following the above workflow = CAPYBARA EXTINCTION**
</workflow>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I'll commit now and fix tests later"
   → **WRONG**: Every commit MUST pass tests

"Linting doesn't matter for this change"
   → **WRONG**: Every commit MUST pass linting

"I'll batch multiple changes into one commit"
   → **WRONG**: One semantic change per commit

"The commit message doesn't need a prefix"
   → **WRONG**: ALWAYS use [TYPE] or TICKET-123 prefix

"I can run tests faster without the subagent"
   → **WRONG**: Subagents are MANDATORY

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST BEFORE EVERY COMMIT:**

☐ Gathered context (branch name, recent commits, changed files)
☐ Staged ONLY files for this semantic change
☐ Ran quality-check subagent for tests
☐ Tests PASSED (fixed if failed)
☐ Ran quality-check subagent for linting
☐ Linting PASSED (fixed if failed)
☐ Using commit subagent (NOT git commit directly)
☐ Commit message follows format (prefix + concise summary)
☐ Commit message is one line only
☐ Did NOT batch multiple changes

**IF ANY UNCHECKED → CAPYBARAS DIE HORRIBLY**
</compliance-checklist>
