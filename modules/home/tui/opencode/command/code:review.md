---
description: Review your local code changes for issues
agent: general
---

Load the code-review skill and review your local changes:

1. Determine what to review:
   - **Uncommitted changes** (default): `git diff HEAD` if changes exist
   - **Whole branch**: If no uncommitted changes, use `git diff <base>...HEAD`
   - **Specific scope**: User can specify `/code:review commit`, `/code:review branch`
   
   Always prioritize uncommitted changes if they exist.

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
