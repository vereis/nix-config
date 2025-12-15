---
description: Create a pull request with quality checks
agent: code-pr
subtask: true
---

Create a pull request following git-workflow skill standards.

1. Run quality checks first (use discovery skill for CI commands)
2. If checks fail, return EXACT error - do not fix
3. Create PR with proper title and description
4. Return PR URL or EXACT error message

Context: $ARGUMENTS
