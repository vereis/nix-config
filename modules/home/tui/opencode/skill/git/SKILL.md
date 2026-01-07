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
