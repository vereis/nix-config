# Pull Request Best Practices

Creating high-quality pull requests that are easy to review and merge.

## Before Creating a PR

### 1. Run Quality Checks

**CRITICAL: PRs must pass all quality checks before creation!**

Use the `ci-discovery` skill to find and run:
- All tests
- All linters
- Build commands
- Type checks

FAIL FAST if any checks fail - fix issues before creating PR.

### 2. Verify Commits

- All commits follow format from `commits.md`
- Each commit represents atomic change
- Commit messages are clear and descriptive
- No WIP or temp commits

### 3. Update Branch

```bash
# Ensure branch is up to date with base
git checkout main
git pull
git checkout your-branch
git rebase main
```

## PR Title Format

**Match commit format:**
- `[TICKET-123] High level summary of changes`
- `[FEAT] High level summary of changes`

Use the same format as your commits for consistency.

## PR Description

### Structure

Focus on **WHY** rather than **WHAT**:

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

### Guidelines

- **Concise** - 1-3 bullet points per section
- **Context** - Explain why, not what (code shows what)
- **Links** - Always link to related tickets/issues
- **Testing** - Show the change works
- **Breaking changes** - Call out clearly if present

## Discovering PR Templates

Before creating PR, check for templates:

```bash
# Check for PR templates
ls -la .github/PULL_REQUEST_TEMPLATE.md
ls -la .github/pull_request_template.md
ls -la PULL_REQUEST_TEMPLATE.md

# Check recent PRs for style
gh pr list --state merged --limit 5
gh pr view <number>
```

**If template exists:** Follow it EXACTLY

**If no template:** Match the style of recent merged PRs (minimal vs detailed, section format)

## Creating the PR

```bash
# Push branch
git push -u origin your-branch-name

# Create PR
gh pr create --title "[TICKET-123] Title" --body "$(cat <<'EOF'
## Summary
- Brief explanation

## Testing
- How this was tested
EOF
)"
```

## Common Mistakes

❌ Creating PR with failing tests
❌ No description or "see commits"
❌ Giant PRs with unrelated changes
❌ Unclear or missing title
❌ Not linking to related tickets
❌ Rebasing during active review

✅ All checks pass before PR creation
✅ Clear, concise description explaining why
✅ Atomic, focused changes
✅ Descriptive title with ticket reference
✅ Links to all related work
✅ Stable branch during review
