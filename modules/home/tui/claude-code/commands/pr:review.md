---
description: Review a PR and summarize issues
argument-hint: [pr-number-or-url]
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr status:*), Bash(gh repo view:*)
---

## Task

Review the PR identified by `$ARGUMENTS`.

Steps:

1. Fetch PR metadata:
   - !`gh pr view $ARGUMENTS --json number,title,body,headRefName,baseRefName,files,comments,reviews,url`
2. Fetch the diff:
   - !`gh pr diff $ARGUMENTS`
3. Review for correctness, security, maintainability, and tests.

Output:

- Summary
- Critical issues
- Warnings
- Suggestions

Do NOT post comments unless explicitly asked.
