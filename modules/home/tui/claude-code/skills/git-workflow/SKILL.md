---
name: git-workflow
description: "**MANDATORY**: Enforce branch/worktree workflow. Use when starting work, picking up work, creating branches, using git worktrees, or when asked to implement anything non-trivial. Ensures all work happens on correctly named branches, preferably in dedicated worktrees."
allowed-tools:
  - Bash(git status:*)
  - Bash(git branch:*)
  - Bash(git rev-parse:*)
  - Bash(git worktree:*)
  - Bash(git show:*)
  - Bash(git log:*)
user-invocable: true
---

# Git workflow: branches + worktrees

## Non-negotiables
- **All work happens on a branch.** Never commit on `master`/`main`.
- Branch names must follow the conventions below.
- Prefer using a **git worktree per task** so context stays clean and you don’t trample other work.

## Branch naming (Conventional Commit aligned)

### Without ticket
- `feat/<short-kebab>`
- `fix/<short-kebab>`
- `refactor/<short-kebab>`
- `chore/<short-kebab>`
- `docs/<short-kebab>`

### With ticket
- `TICKET-123/feat-short-kebab`
- `TICKET-123/fix-short-kebab`
- `TICKET-123/refactor-short-kebab`

Rules:
- Keep it minimal: no essays.
- Use lowercase + hyphens.

## Worktree workflow

### Detect whether we’re in a worktree
- Use `git rev-parse --is-inside-work-tree` and `git rev-parse --is-bare-repository`.

### If we are asked to "pick up work" or start a new task

If we’re already in a git worktree, create a new dedicated worktree for the new task.

Preferred entrypoint:
- Use the `/worktree:new` command (it creates the worktree in the correct place and handles existing branches).

Steps:
1) Find the *worktree root repo*:
- Run `git rev-parse --git-common-dir`.
- If it ends with `/worktrees/<name>`, you are inside a linked worktree.
- The top-level directory is the parent of that common dir.

2) Create a new worktree directory in the top-level repo
Use:

```
# from the top-level repo directory

git worktree add <TICKET_OR_MIN_DESC> -b <branch-name>
```

- `<TICKET_OR_MIN_DESC>`: directory name, minimal (e.g. `VET-123` or `fix-nix-eval`)
- `<branch-name>`: must follow the branch naming rules above

If the branch already exists:

```
git worktree add <TICKET_OR_MIN_DESC> <branch-name>
```

## Safety checks before doing anything
- If on `master`/`main`: stop and create a branch (or worktree) first.
- If the branch name doesn’t follow conventions: rename it before continuing.
