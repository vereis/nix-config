---
description: Create a pull request with conventional commit format
agent: general
---

Create a PR for the current branch:

1. Load the git skill to understand conventions
2. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
3. Run `git log <base>..HEAD --oneline` to see commits (use detected base branch)
4. Run `git diff <base>...HEAD --stat` to see changed files (use detected base branch)
5. Generate concise PR title: `<type>(<scope>): <description>`
   - Remove redundant words (e.g., "add feature and tests" → "add feature")
   - Keep it minimal but complete
6. Create simple PR description:
   - Bullet list of what changed (no verbose sections)
   - Direct, factual statements only
   - Link related issues if applicable
7. Use `gh pr create --title "..." --body "..."` to create the PR
8. Return the PR URL
