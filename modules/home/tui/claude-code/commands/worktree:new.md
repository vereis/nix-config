---
description: Create a new git worktree for a task (enforces branch naming)
argument-hint: <dir> <branch>

# Branch examples
# - feat/short-kebab
# - feat/TICKET-123
# - feat/TICKET-123-short-kebab
allowed-tools: Bash(git rev-parse:*), Bash(git show-ref:*), Bash(git worktree:*), Bash(realpath:*), Bash(mkdir:*), Bash(test:*), Bash(pwd:*)
---

Create a new worktree for a task.

Args:
- `$1` = directory name (ticket or minimal description)
- `$2` = branch name (must follow our git conventions)

## Task

1) Validate args are provided.
2) Determine the **top-level git repo** for worktree operations:
- Read `git rev-parse --git-common-dir`.
- If it contains `/.git/worktrees/`, derive the main repo root from it.
- Otherwise, use `git rev-parse --show-toplevel`.

3) Create the worktree *next to* the repo root directory:
- `target_dir = <parent-of-repo-root>/$1`
- Fail if `target_dir` already exists.

4) Add worktree:
- If branch `$2` exists locally, run:
  - `git -C <repo-root> worktree add <target_dir> <branch>`
- Otherwise:
  - `git -C <repo-root> worktree add <target_dir> -b <branch>`

5) Print:
- `target_dir`
- branch name
- next command to enter it

Implementation guidance (use Bash tool):
- Use `git show-ref --verify refs/heads/$2` to detect branch existence.
- Use `realpath` to normalize paths.
