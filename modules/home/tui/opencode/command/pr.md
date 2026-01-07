---
description: Create a pull request with conventional commit format
agent: general
---

Create a PR for the current branch:

1. Load the git skill to understand conventions
2. Detect base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
3. Run `git log <base>..HEAD --oneline` to see commits (use detected base branch)
4. Run `git diff <base>...HEAD --stat` to see changed files (use detected base branch)
5. Generate conventional commit-style title: `<type>(<scope>): <description>`
6. Create comprehensive PR description:
   - Summary of changes (1-2 sentences)
   - List of specific changes (bullet points)
   - Testing notes (how to verify)
   - Link any related issues
7. Use `gh pr create --title "..." --body "..."` to create the PR
8. Return the PR URL
