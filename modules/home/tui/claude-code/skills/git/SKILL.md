---
name: git
description: "**MANDATORY**: Load when creating commits or PRs. Covers conventional commits, branching, and PR conventions"
---

# Git Conventions

## Commit Format

```
<type>(<scope>): <description>

[optional footer(s) for breaking changes only]
```

**Important:**
- Keep descriptions concise and complete - avoid optional body unless absolutely necessary
- Breaking changes MUST include `BREAKING CHANGE:` footer explaining the impact
- Prefer self-explanatory single-line commits
- **NEVER use emojis** in commit messages

## Types

| Type | Description | Version Bump |
|------|-------------|--------------|
| feat | New feature | MINOR |
| fix | Bug fix | PATCH |
| docs | Documentation only | - |
| style | Formatting, no code change | - |
| refactor | Code change, no fix/feat | - |
| perf | Performance improvement | PATCH |
| test | Adding/correcting tests | - |
| build | Build system/dependencies | - |
| ci | CI configuration | - |
| chore | Other changes | - |
| revert | Revert previous commit | - |

## Examples

```
feat(auth): add OAuth2 login flow
fix(api): handle null response from payment service
refactor(db): extract query builder into separate module
docs(readme): add installation instructions
revert: remove experimental feature

Refs: 676104e
```

## Branch Naming

**With JIRA ticket:**
- `TICKET-123/feat-description` - Feature with ticket
- `TICKET-456/fix-description` - Bug fix with ticket

**Without JIRA ticket:**
- `feat/<description>` - New features
- `fix/<description>` - Bug fixes
- `refactor/<description>` - Refactoring
- `docs/<description>` - Documentation
- `chore/<description>` - Maintenance

## PR Conventions

**Title format:** `<type>(<scope>): <concise description>`
- Remove redundant words (e.g., "streamline configuration and remove complexity" → "streamline configuration")
- The description should be complete but minimal
- **NEVER use emojis** in PR titles

**Description format:**
- Simple bullet list of what changed (no verbose sections)
- Direct, factual statements
- No dramatic language or over-explanation
- **NEVER use emojis** in PR descriptions
- Link issues if relevant: `Closes #123` or `Fixes #123`

**Example:**
```
refactor(api): simplify authentication flow

- removes legacy OAuth1 support
- consolidates token validation logic
- migrates to new session handler
```

## Breaking Changes

Add `!` after type or `BREAKING CHANGE:` in footer:

```
feat(api)!: change authentication endpoint

BREAKING CHANGE: /auth/login now requires email instead of username
```

## Revert Commits

Use the `revert` type and reference the commit SHA(s) being reverted in a footer:

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

**Important:**
- Use `revert:` type (lowercase, following conventional commits)
- Include `Refs:` footer with the commit SHA(s) being reverted
- Description should briefly explain what is being reverted
- Can revert multiple commits by listing multiple SHAs

## Git History Best Practices

Clean git history is a key success metric. Follow these practices:

### Atomic Commits
- Every commit must be independently functional
- All tests must pass after each commit
- All linting must pass after each commit
- No broken application logic at any commit
- Each commit represents one logical unit of work

### Maintaining Clean History

When iterating on features (especially in PRs), prefer amending/absorbing over fixup commits:

**Available tools:**
- `git commit --amend` - Update the most recent commit
- `git absorb` - Automatically distribute staged changes to relevant commits in your branch

**Avoid interactive workflows**:
- Do NOT use `git rebase -i` (interactive commands are not supported in this environment/workflow)

**Using git-absorb:**
```bash
# Make changes to fix issues in previous commits
git add -A
git absorb
# Changes are automatically distributed to the right commits
```

### When to Amend vs New Commit

**Amend/absorb when:**
- Fixing issues found in code review
- Addressing linting/test failures
- Refining implementation details
- Changes belong logically to existing commits

**New commit when:**
- Adding genuinely new functionality
- Changes represent a new logical unit of work
- Commit has already been pushed to shared branch (unless explicitly rebasing)
