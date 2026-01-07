---
description: Create a pull request with conventional commit format
---

Create a PR for the current branch:

1. Load the git skill to understand conventions
2. Run `git log main..HEAD --oneline` to see commits
3. Run `git diff main...HEAD --stat` to see changed files
4. Generate conventional commit-style title: `<type>(<scope>): <description>`
5. Create comprehensive PR description:
   - Summary of changes (1-2 sentences)
   - List of specific changes (bullet points)
   - Testing notes (how to verify)
   - Link any related issues
6. Use `gh pr create --title "..." --body "..."` to create the PR
7. Return the PR URL
