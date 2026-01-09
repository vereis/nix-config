---
description: Review your local code changes for issues
agent: build
---

Review your local changes for issues and refactoring opportunities.

**Scope (optional):** $ARGUMENTS

## 1. Run Code Review Analysis

Use the `code-reviewer` subagent to analyze the code:

```
Task(subagent: "code-reviewer", prompt: "Analyze code changes. Scope: $ARGUMENTS")
```

The subagent will return structured findings with:
- Summary (files analyzed, issue counts)
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (nice to have)
- Already raised issues (filtered from PR comments)
- Context used (PR, linked issues)

## 2. Present Findings to User

Present the subagent's findings organized by severity:

```
## Code Review Results

### Summary
[From subagent response]

### Critical Issues (X found)
[List each with location, code snippet, problem, and fix recommendation]

### Warnings (X found)
[List each...]

### Suggestions (X found)
[List each...]

### Filtered (already raised)
[List issues already mentioned in PR comments]
```

## 3. Offer to Implement Fixes

After presenting findings, ask:

> "Would you like me to implement any of these fixes? I can:
> - **all** - Fix everything
> - **critical** - Only critical issues
> - **[numbers]** - Specific issues (e.g., "1, 3, 5")
> - **none** - Just wanted the review
>
> I'll create atomic commits for each change, running tests/linting after each one."

## 4. Implement Requested Fixes

If user requests fixes:
1. Create a todo list with each fix as a separate item
2. Implement one fix at a time
3. Run tests and linting after each change
4. Commit atomically after each successful fix
5. Mark todo items complete as you go

Follow the fix recommendations from the subagent's analysis.
