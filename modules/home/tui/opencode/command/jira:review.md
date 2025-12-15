---
description: Review and update existing JIRA tickets to enhanced template standards
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
    jira issue edit*: ask
    jira issue create*: ask
    jira issue comment*: ask
    jira issue link*: ask
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

# JIRA Ticket Review & Update

**MANDATORY**: Consult the `jira` skill before proceeding:
- Read `template.md` for ticket structure standards
- Use `cli-usage.md` for CLI patterns (CRITICAL: /tmp file pattern!)
- Apply `research.md` when gathering context

## One Ticket Rule

Review ONE ticket per session. Clear context between tickets.

## Ticket to Review

$ARGUMENTS

## Workflow

1. **Load JIRA Skill** - Read skill files first
2. **Fetch & Research** - View ticket and gather context
3. **Safety Check** - Warn if "In Progress" or "In Review"
4. **Review Quality** - Analyze against template standards
5. **Draft Improvements** - Transform while preserving ALL original info
6. **Show Changes** - Present analysis and improved draft
7. **Discuss Split** (if needed) - If ticket too large
8. **Get Approval** - Explicit confirmation before changes
9. **Update Ticket(s)** - Use CLI patterns (CRITICAL: /tmp file pattern!)
10. **Verify** - Check updated tickets

## Safety Rules

- Never lose information - preserve original in comments if unsure
- Always add update comment explaining changes
- Preserve intent - scope/AC must match original requirements
- Get approval first - show complete preview before executing
- Check status - warn on "In Progress"/"In Review"
- Maintain links - preserve epic/parent/dependency relationships
- One ticket at a time - never batch process
