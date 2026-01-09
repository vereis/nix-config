---
description: Analyze code for refactoring opportunities and cleanup
agent: build
---

Analyze code for refactoring opportunities.

**Scope (optional):** $ARGUMENTS

## 1. Run Refactoring Analysis

Use the `refactorer` subagent to analyze the code:

```
Task(subagent: "refactorer", prompt: "Analyze for refactoring opportunities. Scope: $ARGUMENTS")
```

The subagent will return structured findings with:
- Summary (scope analyzed, opportunity counts)
- High priority (dead code, inlining, unnecessary polymorphism)
- Medium priority (comments, test quality, minor over-abstraction)
- Low priority (naming, style)
- Patterns observed (codebase conventions to respect)

## 2. Present Findings to User

Present the subagent's findings organized by priority:

```
## Refactoring Opportunities

### Summary
[From subagent response]

### High Priority (X found)
[List each with location, current code, issue, recommendation, rationale]

### Medium Priority (X found)
[List each...]

### Low Priority (X found)
[List each...]

### Codebase Patterns to Respect
[List patterns the subagent identified]
```

## 3. Offer to Implement Refactors

After presenting findings, ask:

> "Would you like me to implement these refactors? I can:
> - **all** - Apply all refactors
> - **high** - Only high priority
> - **[numbers]** - Specific items (e.g., "1, 3, 5")
> - **none** - Just wanted the analysis
>
> I'll create atomic commits for each change, running tests/linting after each one."

## 4. Implement Requested Refactors

If user requests refactors:
1. Create a todo list with each refactor as a separate item
2. Implement one refactor at a time
3. Run tests and linting after each change
4. Commit atomically after each successful refactor
5. Mark todo items complete as you go

Follow the recommendations from the subagent's analysis, respecting the identified codebase patterns.
