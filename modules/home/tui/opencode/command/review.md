---
description: Review recent code changes for issues
agent: general
---

Load the code-review skill and review recent changes:

1. Determine what to review:
   - Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
   - If on a feature branch: `git diff <base>...HEAD` (use detected base branch)
   - If recent commit: `git diff HEAD~1`
   - Ask user if unclear

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
