# JIRA Research Workflows

## Mandatory

**MANDATORY**: Research existing context before creating/updating tickets when relevant.
**CRITICAL**: Don't over-research - only gather what's needed for the ticket.
**NO EXCEPTIONS**: Finding proper actors, patterns, and context improves ticket quality.

## When to Research

Research existing context when:
- User mentions existing JIRA ticket numbers (e.g., "based on DI-1234")
- User references GitHub PRs or issues
- User mentions specific code files or features
- User says "similar to X" or "follow pattern from Y"
- Reviewing/updating existing tickets
- Need to understand current implementation before designing

**Skip research if:** User provides completely new requirements with no existing context.

## Research Goals

1. **Understand current implementation** before designing ticket
2. **Find defaults/constants** that should be explicitly documented
3. **Identify similar patterns** in codebase for Dev Notes
4. **Discover relationships** between tickets/features
5. **Gather context** from related PRs, commits, or discussions

## Viewing JIRA Tickets

```bash
# View single ticket
jira issue view DI-1234
jira issue view DI-1234 --plain  # Easier parsing

# Extract specific information
jira issue view DI-1234 --plain | grep "Status:"
jira issue view DI-1234 --plain | grep -E "(Epic|Parent):"
jira issue view DI-1234 --plain | grep "Assignee:"
jira issue view DI-1234 --plain | grep "Type:"

# List tickets
jira issue list --project DI
jira issue list --project DI --status "To Do"
jira issue list --project DI --assignee username
jira issue list --project DI --created-after "-30d"
```

## Viewing GitHub PRs and Issues

```bash
# View specific PR
gh pr view 123

# List recent PRs
gh pr list --limit 20
gh pr list --search "medication draft"

# View specific issue
gh issue view 456

# List recent issues
gh issue list --limit 20
gh issue list --search "medication sync"

# Get repo details
gh repo view
```

## Searching Codebase

```bash
# Search for function/module names
rg "prescribe_medication" --type elixir

# Find configuration
rg "MEDICATION_STATUSES" --type elixir

# Search for patterns
rg "def draft\?" --type elixir
rg -i "medication draft" --type elixir  # Case-insensitive

# Find files
find . -name "*medication*.ex"
find ./lib -name "*.ex" | grep medication
```

## Finding Defaults and Constants

```bash
# Check config files
cat config/config.exs | grep -i medication
cat config/dev.exs | grep -i medication

# Search seed data for roles/actors
cat priv/repo/seeds.exs | grep -i "role"
cat priv/repo/seeds.exs | grep -i "permission"

# Find constants
rg "DEFAULT_.*STATUS" --type elixir
rg "@default" --type elixir

# Example: Finding actors
cat priv/repo/seeds.exs | grep -A 5 "roles"
rg "can_prescribe" --type elixir
rg "permission" --type elixir | head -20
```

## Git History Research

```bash
# Search commit messages
git log --grep="medication" --oneline

# View specific commit
git show abc123

# See what changed in a file
git log --oneline -- lib/app/medications.ex

# View file at specific commit
git show abc123:lib/app/medications.ex

# Recent commits
git log --oneline -20
git log --oneline -10 -- lib/app/medications.ex

# Who changed this line?
git blame lib/app/medications.ex | grep "draft"
```

## Research Workflow Examples

### Example 1: Creating Similar Ticket

User: "Create a ticket similar to DI-1234 but for lab results"

```bash
# 1. View reference ticket
jira issue view DI-1234

# 2. Check if there's a PR linked
# (Look in ticket description or comments for PR number)

# 3. View the PR implementation
gh pr view 567

# 4. Search for similar lab results code
rg "lab_result" --type elixir

# 5. Find lab results files
cat lib/app/lab_results.ex | head -50

# 6. Check for configuration
cat config/config.exs | grep lab_result
```

### Example 2: Reviewing Existing Ticket

User: "Review DI-5678 and improve it"

```bash
# 1. View current ticket
jira issue view DI-5678

# 2. Check status and assignee
jira issue view DI-5678 --plain | grep -E "(Status|Assignee):"

# 3. Check for related tickets
jira issue view DI-5678 --plain | grep -i "relates\|blocks\|epic"

# 4. If ticket mentions code, search it
rg "MedicationService" --type elixir

# 5. View relevant files
cat lib/app/medication_service.ex

# 6. Check for similar implementations
rg "def prescribe" --type elixir
```

### Example 3: Understanding Feature Context

User: "Add medication draft status, check how orders handle drafts"

```bash
# 1. Search for existing draft implementations
rg "draft" --type elixir | grep -i order

# 2. View order files
cat lib/app/orders.ex | grep -A 20 "draft"

# 3. Check configuration
rg "DRAFT_STATUS" --type elixir

# 4. Find similar patterns in database
cat priv/repo/migrations/*.exs | grep -i draft

# 5. Check seed data for status values
cat priv/repo/seeds.exs | grep -i status
```

### Example 4: Finding Related PRs

User: "Follow the pattern from the recent invoice refactor"

```bash
# 1. Search recent PRs
gh pr list --limit 20 --search "invoice refactor"

# 2. View the PR
gh pr view 789

# 3. See what files changed
gh pr view 789 --json files --jq '.files[].path'

# 4. View specific file changes
gh pr diff 789

# 5. Check related JIRA tickets mentioned in PR
# (Look in PR description for ticket references)
jira issue view DI-9999
```

## Documenting Research Findings

### In Dev Notes

```markdown
**Dev Notes:**
- Similar draft pattern exists in Orders (lib/app/orders.ex:234)
- Medication status constants defined in config/config.exs:MEDICATION_STATUSES
- Invoice sync happens via MedicationInvoiceWorker background job
- Reference PR #567 for similar implementation approach
```

### In Ticket Comments

When updating existing tickets, document what you found:

```bash
jira issue comment add DI-1234 --no-input "$(cat <<'EOF'
Research findings:
- Related to DI-5678 (implements similar draft workflow for orders)
- PR #567 provides implementation pattern to follow
- Default status values in config/config.exs lines 45-50
- Similar validation logic in lib/app/validators/medication_validator.ex:89
EOF
)"
```

## Research Checklist

Before creating/updating a ticket, verify you've:

- [ ] Viewed referenced JIRA tickets
- [ ] Checked for related PRs/issues
- [ ] Searched codebase for similar patterns
- [ ] Found relevant configuration/constants
- [ ] Identified specific files with line numbers
- [ ] Discovered user roles/actors in seed data
- [ ] Checked for existing implementations to reference

**Only research what's relevant** - don't overdo it!
