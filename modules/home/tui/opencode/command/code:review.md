---
description: Review your local code changes for issues
agent: general
---

Review your local changes for issues and refactoring opportunities.

**Scope (optional):** $ARGUMENTS

## 1. Determine Scope

Default to reviewing the **entire branch** against base:
```bash
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
git diff <base>...HEAD
```

If user specifies a different scope (e.g., `commit`, file path), use that instead.

## 2. Gather Context

Check if there's an associated PR for context:
```bash
gh pr view --json number,title,body,comments,url 2>/dev/null
```

If PR exists:
- **Extract linked issues**: Parse body for GitHub issue links (`#123`, `org/repo#123`) and JIRA ticket IDs (`[A-Z]+-\d+`)
- **Read linked issues**: Use `gh issue view` for GitHub issues
- **Read JIRA tickets**: Try `jira issue view TICKET-ID --plain` (may not be available in all repos)
- **Check existing comments**: Note concerns already raised in PR comments to avoid duplicating feedback

## 3. Run Reviews in Parallel

Use subagents to run code review and refactoring analysis in parallel:

**Subagent 1 - Code Review:**
- Load the code-review skill
- Analyze against: Security, Performance, Maintainability, Correctness, Testing, Architecture

**Subagent 2 - Refactoring:**
- Load the refactoring skill
- Analyze against: Dead code, inlining opportunities, over-abstraction, comment quality, test coverage

## 4. Consolidate Findings

Merge results from both subagents, deduplicating overlapping concerns.

Filter out any issues already raised in existing PR comments.

## 5. Report by Severity

Organize findings:
- **Critical**: Must fix immediately (security, correctness issues)
- **Warning**: Should fix (performance, maintainability)
- **Suggestion**: Nice to have (refactoring, style)

For each finding, provide:
- Location (file:line)
- Current code snippet
- Issue description
- Specific fix recommendation with code example

## 6. Offer to Implement

After presenting findings, ask:

> "Would you like me to implement any of these fixes? I'll create atomic commits for each change, running tests/linting after each one."
