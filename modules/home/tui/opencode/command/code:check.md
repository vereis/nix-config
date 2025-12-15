---
description: Run quality checks (tests, linting)
agent: code-check
subtask: true
---

Run quality checks on the codebase.

1. Use discovery skill (ci) to find correct commands
2. Run tests using EXACT commands from CI
3. Run linting using EXACT commands from CI
4. Return success or EXACT error message - do not investigate or fix

Context: $ARGUMENTS
