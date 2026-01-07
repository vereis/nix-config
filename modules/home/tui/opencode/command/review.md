---
description: Review recent code changes for issues
agent: general
---

Load the code-review skill and review recent changes:

1. Determine what to review (ask user if unclear):
   - **Most recent commit**: `git show HEAD` (default if no argument)
   - **Unstaged changes**: `git diff HEAD`
   - **Whole PR/branch**: Detect base with `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`, then `git diff <base>...HEAD`
   - **Specific commit**: `git show <commit-hash>`
   
   User can specify scope: `/review commit`, `/review unstaged`, `/review pr`, `/review <hash>`

2. Load the code-review skill for the checklist

3. Analyze each changed file against the checklist:
   - Security
   - Performance
   - Maintainability
   - Correctness
   - Testing
   - Architecture (design patterns, structure, separation of concerns)

4. Report issues by severity:
   - 🔴 Critical: Must fix immediately
   - 🟡 Warning: Should be strongly considered and fixed unless there's good reason
   - 🔵 Suggestion: Nice to have

5. Provide specific fix recommendations with code examples
