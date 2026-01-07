---
name: git
description: "**MANDATORY**: Load when creating commits or PRs. Covers conventional commits, branching, and PR conventions"
---

# Git Conventions

## Commit Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

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
```

## Branch Naming

- `feat/<description>` - New features
- `fix/<description>` - Bug fixes
- `refactor/<description>` - Refactoring
- `docs/<description>` - Documentation
- `chore/<description>` - Maintenance

## PR Conventions

- **Title**: Same format as commit message
- **Description**: Summary, changes list, testing notes
- **Link issues**: `Closes #123` or `Fixes #123`

## Breaking Changes

Add `!` after type or `BREAKING CHANGE:` in footer:

```
feat(api)!: change authentication endpoint

BREAKING CHANGE: /auth/login now requires email instead of username
```

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
- `git rebase -i <base>` - Interactively reorder, squash, or edit commits

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
