---
name: ci-discovery
description: MANDATORY for quality-check, commit, and pr agents when discovering test, lint, and build commands. Prioritizes CI configurations as source of truth, with intelligent fallback to project manifests. Always consult this skill before running quality checks or creating PRs.
---

<mandatory>
**CRITICAL**: ALWAYS use this skill to discover CI/quality check commands.
**NO EXCEPTIONS**: Guessing commands = broken CI = capybara extinction.
**CAPYBARA DECREE**: CI files are source of truth, NEVER invent commands or capybaras will cry.
</mandatory>

<core-principles>
- **CI pipelines are the source of truth** - What CI runs is what must pass
- **Exact command replication** - Use the EXACT commands from CI, don't infer or modify
- **Intelligent fallback** - Only use project files if no CI exists
- **Multi-command support** - Extract all relevant commands (test, lint, build, typecheck)
- **Cross-platform awareness** - Handle different CI systems and project structures
- **NEVER guess** - If no commands found, ask for guidance
</core-principles>

<structure>
This skill provides comprehensive CI command discovery knowledge:

- **`discovery.md`** - How to discover CI files and project manifests
- **`commands.md`** - How to extract specific commands from CI configurations
- **`fallback.md`** - Project file patterns when no CI exists

**PROACTIVELY** consult these files when discovering commands or capybaras will suffer!
</structure>

<quick-reference>
**Discovery Process (MANDATORY):**

1. Check CI pipeline files FIRST (`.github/workflows/*.yml`, `.gitlab-ci.yml`, etc.)
2. Extract EXACT commands from CI configurations
3. Only fallback to project files if NO CI exists
4. Return structured command list for requested check types

**For quality-check agent:**
- Discover test/lint commands from CI
- Find test/lint scripts in project files (if no CI)
- Return exact command to run

**For commit agent:**
- Verify quality checks exist before committing
- Discover lint/format commands

**For pr agent:**
- Discover ALL quality check commands (test + lint + build)
- Replicate CI workflow locally before PR creation
- Ensure PR will pass CI checks
</quick-reference>

<proactive-triggers>
**ALWAYS use this skill when:**
- Running quality checks (tests/lints)
- Creating commits (need lint commands)
- Creating PRs (need ALL CI commands)
- User asks to "run tests" or "run linting"
- ANY quality assurance operation

**Don't wait to be asked - BE PROACTIVE or capybaras will be disappointed!**
</proactive-triggers>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I know the project uses npm test"
   → **WRONG**: Check CI to be sure

"I'll just run the standard command for this language"
   → **WRONG**: CI might have custom setup or flags

"CI files are too complicated to parse"
   → **WRONG**: Extract EXACT commands anyway

"Project files are good enough"
   → **WRONG**: CI is ALWAYS the source of truth if it exists

"I'll skip the install steps from CI"
   → **WRONG**: Include ALL commands CI runs

**ALL EXCUSES = CAPYBARA DEATH**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST WHEN DISCOVERING COMMANDS:**

☐ Checked for CI files FIRST (GitHub Actions, GitLab CI, etc.)
☐ Extracted EXACT commands from CI (if found)
☐ Did NOT modify or infer commands
☐ Only checked project files if NO CI exists
☐ Included setup/install commands from CI
☐ Preserved command order from CI
☐ Did NOT guess or invent commands
☐ Asked for guidance if no commands found

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
</compliance-checklist>
