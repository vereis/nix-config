---
description: Planning and analysis agent with restricted permissions - uses Opus for deep thinking
mode: primary
model: anthropic/claude-opus-4
temperature: 0.1
tools:
  write: false
  edit: false
permission:
  bash:
    ls*: allow
    cat*: allow
    grep*: allow
    rg*: allow
    find*: allow
    head*: allow
    tail*: allow
    tree*: allow
    git status: allow
    git diff*: allow
    git log*: allow
    git show*: allow
    git branch*: allow
    git grep*: allow
    git ls-files*: allow
    git ls-tree*: allow
    git rev-parse*: allow
    git describe*: allow
    git tag: allow
    git remote*: allow
    git config --get*: allow
    git config --list: allow
---

A restricted agent designed for planning and analysis with Opus 4.1 for superior reasoning capability.

All file edits and bash commands require approval to prevent unintended changes.

Use this agent when you want deep analysis, code review, architectural planning, or suggestions without making modifications to your codebase.
