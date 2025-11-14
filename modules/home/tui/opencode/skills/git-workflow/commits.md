# Commit Message Format

Commit messages should be concise, consistent, and informative.

## Format

**If working on a ticket:**
```
[TICKET-123] High level summary of changes
```

**Otherwise:**
```
[FEAT/BUG/CHORE] High level summary of changes
```

## Rules

- **One line only** - No multi-line commits
- **No fluff** - Be direct and mechanical
- **High level summary** - What was accomplished, not how
- **Present tense** - "Add feature" not "Added feature"
- **Imperative mood** - "Fix bug" not "Fixes bug"

## Prefix Guidelines

Use appropriate prefixes for non-ticket commits:

- **FEAT** - New features or functionality
- **BUG** - Bug fixes
- **CHORE** - Maintenance tasks (dependency updates, refactoring, cleanup)
- **DOCS** - Documentation changes
- **PERF** - Performance improvements
- **TEST** - Test additions or modifications

## Good Examples

- `[VS-456] Add user authentication middleware`
- `[GH-789] Fix memory leak in data processor`
- `[FEAT] Implement real-time notifications`
- `[BUG] Fix null pointer in payment processor`
- `[CHORE] Update dependencies to latest versions`
- `[PERF] Optimize database query performance`

## Bad Examples

❌ `[PROJ-456] Add authentication middleware and also fix some linting issues and update docs`
- **Why:** Too long, batches multiple concerns

❌ `[PROJ-456] This commit adds user authentication middleware to handle login requests`
- **Why:** Too wordy, unnecessary preamble

❌ `Update code`
- **Why:** No prefix, vague, doesn't explain what changed

❌ `WIP`
- **Why:** Not descriptive, should not be committed to shared branches

❌ `Fix stuff`
- **Why:** No prefix, too vague

## Finding Context

Before committing, gather context to write a good message:

```bash
# Check branch name for ticket numbers
git branch --show-current

# Check recent commits for patterns
git log --oneline -5

# See what files changed
git status
git diff --stat

# Check staged changes
git diff --cached --stat
```

## Commit Granularity

Each commit should:
- Represent a single logical change
- Pass all tests
- Pass all linters
- Be independently revertable

If your commit message needs "and" or "also", you're probably batching multiple changes. Split them into separate commits.
