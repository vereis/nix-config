# Branch Naming Conventions

Consistent branch naming makes it easy to understand the purpose and context of work.

## Format

**For ticket/issue work:**
```
<ticket-id>/<short-description>
```

**For non-ticket work:**
```
<type>/<short-description>
```

## Examples

**Ticket-based branches:**
- `VS-1234/add-user-auth`
- `GH-456/fix-memory-leak`
- `PROJ-789/update-api-format`

**Type-based branches:**
- `feat/real-time-notifications`
- `bug/payment-processor-crash`
- `chore/update-dependencies`
- `refactor/extract-service-layer`
- `docs/api-documentation`

## Branch Types

- **feat/** - New features
- **bug/** - Bug fixes
- **chore/** - Maintenance work
- **refactor/** - Code restructuring
- **docs/** - Documentation updates
- **perf/** - Performance improvements
- **test/** - Test additions/modifications

## Guidelines

- Use lowercase with hyphens (kebab-case)
- Keep descriptions short but meaningful
- Use ticket ID as prefix for ticket work
- Use type prefix for non-ticket work

## Branch Lifecycle

1. **Create** from main/master/staging/production/etc
2. **Work** with atomic commits
3. **Push** regularly to remote
4. **PR** when complete
5. **Merge** to target branch

## Working with Branches

```bash
# Create new branch from main
git checkout main
git pull
git checkout -b VS-1234/add-feature

# Push branch to remote
git push -u origin VS-1234/add-feature

# Keep branch updated with main
git checkout main
git pull
git checkout VS-1234/add-feature
git rebase main
```

## When to Branch

- Always branch for new work
- One branch per ticket/issue
- One branch per logical feature (if no ticket)
- Never commit directly to main/master/staging/production
