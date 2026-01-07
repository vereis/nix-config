---
description: Review recent code changes for issues
agent: general
---

Load the code-review skill and review recent changes:

1. Determine what to review:
   - If on a feature branch: `git diff main...HEAD`
   - If recent commit: `git diff HEAD~1`
   - Ask user if unclear

2. Load the code-review skill for the checklist

3. Analyze each changed file against the checklist:
   - Security
   - Performance
   - Maintainability
   - Correctness
   - Testing

4. Report issues by severity:
   - 🔴 Critical: Must fix
   - 🟡 Warning: Should fix
   - 🔵 Suggestion: Nice to have

5. Provide specific fix recommendations with code examples
