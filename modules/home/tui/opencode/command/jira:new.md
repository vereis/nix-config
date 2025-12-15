---
description: Create a JIRA ticket with guided workflow
tools:
  write: false
  edit: false
permission:
  bash:
    ls*: allow
    cat*: allow
    grep*: allow
    rg*: allow
    find*: allow
    head*: allow
    tail*: allow
    tree*: allow
    echo*: allow
    touch /tmp/*: allow
    jira issue view*: allow
    jira issue list*: allow
    jira issue create*: ask
    jira project list*: allow
    gh issue view*: allow
    gh issue list*: allow
    gh repo view*: allow
    git status: allow
    git diff*: allow
    git log*: allow
    git show*: allow
    git branch*: allow
    git grep*: allow
    git ls-files*: allow
    git ls-tree*: allow
    git rev-parse*: allow
    git describe*: allow
    git tag: allow
    git remote*: allow
    git config --get*: allow
    git config --list: allow
---

# JIRA Ticket Creation

**MANDATORY**: Consult the `jira` skill before proceeding:
- Read `template.md` for ticket structure
- Use `cli-usage.md` for CLI patterns (CRITICAL: /tmp file pattern!)
- Apply `research.md` when gathering context

## One Ticket Rule

Process ONE ticket at a time. Clear context between tickets.

## User Input

$ARGUMENTS

## Workflow

1. **Load JIRA Skill** - Read skill files first
2. **Research** (if needed) - If user references existing tickets/PRs/code
3. **Gather Requirements** - Ask clarifying questions
4. **Draft Ticket** - Follow template structure exactly
5. **Review & Iterate** - Show draft, iterate until approved
6. **Get Confirmation** - "Ready to create? (yes/no)"
7. **Create Ticket** - Use CLI patterns (CRITICAL: /tmp file pattern!)
8. **Report** - Return ticket URL

## Principles

- **Outcomes over implementation** - Describe what changes, not how
- **Specific actors** - Use real roles from codebase, not "user"
- **Scope = WHERE** - Pages/components affected
- **Acceptance = DONE** - Observable inputs/outputs
- **One concern per ticket** - Split complex requests
- **Always review** - Show draft before creating
