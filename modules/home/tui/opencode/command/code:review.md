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

## 2. Use Subagents for Research (Parallel)

Use subagents to gather context - this is **research only**, not the actual review:

**Subagent 1 - PR Context (if PR exists):**
```bash
gh pr view --json number,title,body,comments,url 2>/dev/null
```
- Extract GitHub issues from PR body: `#123`, `org/repo#123`
- Extract JIRA tickets: Pattern `[A-Z]+-\d+`
- Fetch each: `gh issue view` for GitHub, `jira issue view TICKET-ID --plain` for JIRA
- Return summaries of requirements/context

**Subagent 2 - Existing Feedback:**
- If PR exists, analyze existing comments
- Return list of concerns already raised (to avoid duplicating)

**Subagent 3 - Best Practices Research:**
- Based on the languages/frameworks in the diff, research relevant best practices
- Load refactoring skill for language-specific guidance (e.g., `elixir.md` for Elixir code)
- Return relevant patterns and anti-patterns to watch for

## 3. Primary Agent: Perform the Review

**The primary agent does the actual review work**, using context from subagents.

**Skip generated files** - don't review files we have little control over:
- `*.gen.ts`, `*.gen.js`, `*.generated.*`
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `*.min.js`, `*.min.css`
- Files in `node_modules/`, `vendor/`, `dist/`, `build/`
- GraphQL generated files (`*.graphql.ts`, `*_gen.go`, etc.)
- Proto generated files (`*.pb.go`, `*.pb.ex`, etc.)
- Migration files (often auto-generated or rarely worth commenting on)

Load skills:
- Load the code-review skill
- Load the refactoring skill

Analyze the diff against:
- **Code Review**: Security, Performance, Maintainability, Correctness, Testing, Architecture
- **Refactoring**: Dead code, inlining opportunities, over-abstraction, comment quality, test coverage

Filter out any issues already raised in existing PR comments (from subagent 2).

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
