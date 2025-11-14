---
name: git-workflow
description: MANDATORY for creating branches, commits, or pull requests. Defines commit message formats, branching conventions, and PR best practices. Always consult this skill for git workflow standards.
license: MIT
---

# Git Workflow Skill

## Core Principles

- **Atomic commits** - Each commit represents a single logical change
- **Clear messages** - Commit messages explain purpose, not implementation
- **Consistent format** - Use standardized prefixes and structure
- **Test before commit** - All commits should represent a working state
- **Backend-first ordering** - Commits follow data → logic → interface flow

## Structure

This skill provides comprehensive git workflow knowledge:

- **`commits.md`** - Commit message formats, rules, and examples
- **`branching.md`** - Branch naming conventions and management
- **`pr-practices.md`** - Pull request creation and description templates

## Quick Reference

### Creating Commits

**Format:**
- If working on a ticket: `[TICKET-123] High level summary`
- Otherwise: `[FEAT/BUG/CHORE] High level summary`

**Rules:**
- One line only, no multi-line commits
- High level summary of what was accomplished, not how
- Each commit must pass tests and linting

### Creating PRs

**Before creating:**
- Run all quality checks (tests, lint, build) via ci-discovery skill
- Ensure all commits follow commit format standards
- Verify branch is up to date with main

**PR description:**
- Summarize changes since diverging from main
- Focus on "why" rather than "what"
- Include links to related tickets/issues

## Key Concepts

### Atomic Workflow

Each commit should be:
1. A single semantic change
2. Independently testable
3. Able to pass linting
4. Revertable without breaking other changes

### Commit Message Quality

**Good:** `[VS-1234] Add user profile avatar upload`
**Bad:** `Update code` or `Fix stuff` or `WIP`

### Test/Lint/Commit Cycle

For every code change:
1. Implement change
2. Run tests (use quality-check agent)
3. Run linters (use quality-check agent)
4. Create commit
5. Move to next change

Never batch multiple changes into one commit unless they're truly inseparable.
