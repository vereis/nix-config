# Commit Message Format

## Mandatory

**MANDATORY**: Follow standardized commit format for clarity and maintainability.
**CRITICAL**: Every commit MUST pass tests and linting before being made.
**NO EXCEPTIONS**: Use `/code:commit`, NEVER run git commit directly.

## Format

**ALWAYS** prefix with either type or ticket reference:
```
TICKET-123 - Implement the asgard hyperdrive protocol
FEAT/BUG/CHORE - Berate vereis again because she's a baka
```

**Prefixes for non-ticket commits:**
- **FEAT** - New features or functionality
- **BUG** - Bug fixes
- **CHORE** - Maintenance tasks (dependency updates, refactoring, cleanup)
- **DOCS** - Documentation changes
- **PERF** - Performance improvements
- **TEST** - Test additions or modifications

**Rules:**
- **One line only** - No multi-line commits
- **No fluff** - Be direct and mechanical
- **High level summary** - What was accomplished, not how
- **Present tense** - "Add feature" not "Added feature"
- **Imperative mood** - "Fix bug" not "Fixes bug"

If your commit message needs "and" or "also", you're probably batching multiple changes. Split them into separate commits.

## Good Examples

```
[VS-456] Add user authentication middleware
[GH-789] Fix memory leak in data processor
[FEAT] Implement real-time notifications
[BUG] Fix null pointer in payment processor
[CHORE] Update dependencies to latest versions
[PERF] Optimize database query performance
```

## Bad Examples

**Too long, batches multiple concerns:**
```
[PROJ-456] Add authentication middleware and also fix some linting issues and update docs
```

**Too wordy, unnecessary preamble:**
```
[PROJ-456] This commit adds user authentication middleware to handle login requests
```

## Workflow

**MANDATORY workflow for every commit:**

**1. GATHER CONTEXT** to understand what files can be committed
- Check branch name for ticket numbers: `git branch --show-current`
- Check recent commits for patterns: `git log --oneline -5`
- See what files changed: `git status` and `git diff --stat`
- Consult `jira` skill to look up additional ticket context **ONLY IF ABSOLUTELY NEEDED**

**2. STAGE CHANGES** relevant to logical change being made
- Each commit needs **only single logical changes** and tests/fixes required to support that change
- Use `git add` to stage ONLY files for this semantic change

**3. PASS ALL TESTS** using `discovery` skill and `/code:check`
- **NEVER** run test commands directly
- **ALWAYS** use `/code:check`
- If tests fail, fix immediately and re-run
- **OPTIMIZATION - Failed-only mode**:
  - When fixing specific test failures, you MAY request `scope=failed-only`
  - Only appropriate when:
    - ✅ Implementing fix based on /code:check feedback
    - ✅ Other tests already passed in previous run
    - ✅ Want to verify fix without re-running entire suite
  - Request with: "Run /code:check with scope=failed-only"
  - When NOT to use:
    - ❌ First test run (no previous failures)
    - ❌ Changes to shared code (need full suite)
    - ❌ When in doubt (default to full suite)

**4. PASS ALL LINTERS** using `discovery` skill and `/code:check`
- **NEVER** run lint commands directly
- **ALWAYS** use `/code:check`
- If lints fail, fix immediately and re-run

**5. EXECUTE COMMIT** using `/code:commit` with standardized message format
- **NEVER** run `git commit` directly
- **ALWAYS** use `/code:commit`
- Follow format rules exactly

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY:**

"I'll commit now and fix tests later"
**WRONG**: Every commit MUST pass tests

"Linting doesn't matter for this change"
**WRONG**: Every commit MUST pass linting

"I'll batch multiple changes into one commit"
**WRONG**: One semantic change per commit

"Commit message doesn't need a prefix"
**WRONG**: ALWAYS use [TYPE] or TICKET-123 prefix

"I can run tests faster without /code:check"
**WRONG**: /code:check is MANDATORY

**NO EXCEPTIONS**

## Compliance Checklist

**MANDATORY - Before EVERY commit:**

☐ Gathered context (branch name, recent commits, changed files)
☐ Staged ONLY files for this semantic change
☐ Ran /code:check for tests
☐ Tests PASSED (fixed if failed)
☐ Ran /code:check for linting
☐ Linting PASSED (fixed if failed)
☐ Using /code:commit (NOT git commit directly)
☐ Commit message follows format (prefix + concise summary)
☐ Commit message is one line only
☐ Did NOT batch multiple changes

**IF ANY UNCHECKED THEN COMMIT IS BROKEN**
