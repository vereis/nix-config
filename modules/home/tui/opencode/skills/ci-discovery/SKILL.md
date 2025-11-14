---
name: ci-discovery
description: MANDATORY for quality-check, commit, and pr agents when discovering test, lint, and build commands. Prioritizes CI configurations as source of truth, with intelligent fallback to project manifests. Always consult this skill before running quality checks or creating PRs.
license: MIT
---

# CI Discovery Skill

## Core Principles

- **CI pipelines are the source of truth** - What CI runs is what must pass
- **Exact command replication** - Use the EXACT commands from CI, don't infer or modify
- **Intelligent fallback** - Only use project files if no CI exists
- **Multi-command support** - Extract all relevant commands (test, lint, build, typecheck)
- **Cross-platform awareness** - Handle different CI systems and project structures

## Structure

This skill provides comprehensive CI command discovery knowledge:

- **`discovery.md`** - How to discover CI files and project manifests
- **`commands.md`** - How to extract specific commands from CI configurations
- **`fallback.md`** - Project file patterns when no CI exists

## Quick Reference

### Discovering Commands

**Priority order:**
1. Check CI pipeline files FIRST (`.github/workflows/*.yml`, `.gitlab-ci.yml`, etc.)
2. Extract EXACT commands from CI configurations
3. Only fallback to project files if no CI exists
4. Return structured command list for requested check types

### Common Use Cases

**For quality-check agent:**
- Discover test/lint commands from CI
- Find test/lint scripts in package.json/mix.exs/Cargo.toml
- Return exact command to run

**For commit agent:**
- Verify quality checks exist before committing
- Discover lint/format commands

**For pr agent:**
- Discover ALL quality check commands (test + lint + build)
- Replicate CI workflow locally before PR creation
- Ensure PR will pass CI checks

## Key Concepts

### CI as Source of Truth

CI pipelines define what MUST pass for code to be accepted. Local quality checks should replicate CI exactly, not make assumptions.

### Command Extraction

Don't infer or modify commands. If CI runs `npm ci && npm run test:ci`, run that EXACT sequence locally.

### Fallback Strategy

Only use project file patterns when no CI exists. If CI exists but doesn't have test/lint steps, that's meaningful - don't invent commands.

### Multi-System Support

This skill covers:
- GitHub Actions (`.github/workflows/*.yml`)
- GitLab CI (`.gitlab-ci.yml`)
- CircleCI (`.circleci/config.yml`)
- Travis CI (`.travis.yml`)
- Buildkite (`.buildkite/pipeline.yml`)
- Jenkins (`Jenkinsfile`)
- Project manifests (`package.json`, `mix.exs`, `Cargo.toml`, `Makefile`, etc.)

## Error Handling

**If no commands found:**
- Report what was checked
- Don't make assumptions
- Ask primary agent/user for guidance

**If commands fail:**
- Report exact failure
- Don't try alternative commands
- Let primary agent handle fixes
