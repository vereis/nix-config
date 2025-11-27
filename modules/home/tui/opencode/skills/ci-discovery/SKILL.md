---
name: ci-discovery
description: MANDATORY for discovering test, lint, and build commands. Prioritizes CI configurations as source of truth, with intelligent fallback to project manifests. Always consult this skill before running quality checks, build commands, or creating PRs.
---

<mandatory>
**MANDATORY**: CI files are source of truth for a system, NEVER invent commands or guess what to run.
**CRITICAL**: ALWAYS use this skill to discover CI/quality check commands.
**NO EXCEPTIONS**: Guessing commands = broken CI = wasted time and money.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context. DO NOT spawn additional subagents from this skill. Simply follow the discovery process and return results to the primary agent.
</subagent-context>

<core-principles>
1. **CI pipelines are the source of truth** - What CI runs is what must pass
2. **Exact command replication** - Use the EXACT commands from CI, don't infer or modify
3. **Intelligent fallback** - Only use project files if NO CI exists
4. **Never guess** - If no commands found, ask for guidance
</core-principles>

<discovery-process>
**STEP 1: Check CI Files FIRST**

Search for CI configurations. These usually live in the root of a repository so if not found there, check parent directories as you may be in a monorepo.

- **GitHub Actions**: `.github/workflows/*.{yml,yaml}`
- **GitLab CI**: `.gitlab-ci.yml`
- **CircleCI**: `.circleci/config.yml`
- **Travis CI**: `.travis.yml`
- **Buildkite**: `.buildkite/pipeline.yml`
- **Jenkins**: `Jenkinsfile`

**STEP 2: Extract EXACT Commands from CI**

Look for these command types in CI jobs/steps:

**Test commands:**
- `npm test`, `mix test`, `cargo test`, `pytest`, `go test`, `make test`

**Lint commands (COMPREHENSIVE - find ALL):**
- Standard linters: `eslint`, `mix format --check-formatted`, `cargo clippy`, `ruff check`
- Format checkers: `prettier --check`, `black --check`, `cargo fmt -- --check`
- Style checkers: `rubocop`, `pylint`, `flake8`, `credo`, `golangci-lint`
- Security linters: `npm audit`, `cargo audit`, `bundle audit`
- Custom scripts: `npm run lint:custom`, `./scripts/lint.sh`
- Database validations: `mix ecto.validate`, schema checks
- Warnings-as-errors: `--warnings-as-errors`, `-D warnings`, `--strict`

**Build commands:**
- `npm run build`, `mix compile`, `cargo build`, `make build`, `tsc`

**Typecheck commands:**
- `tsc --noEmit`, `mypy`, `dialyzer`, `flow check`

**Database Linting/Checks:**
- `sqlfluff lint`, `pg_format --check`, `dbt test`, `mix excellent_migrations.*`

**Extraction rules:**
1. Preserve order - Run commands in same order as CI
2. Include setup - If CI runs `npm ci` before `npm test`, include both
3. Combine with && - Chain commands that CI runs sequentially
4. Use exact syntax - `npm test` vs `npm run test` matters, match CI exactly
5. Ignore non-quality steps - Skip deploy, notify, artifact upload
6. Handle conditionals - If CI has `if` conditions, include commands only if they would run in normal flow
7. Make sure to capture ALL relevant commands - missing one can lead to failures, this extends to custom scripts and checks

**Example** - Look for `jobs.<job_id>.steps[].run`:
```yaml
jobs:
  test:
    steps:
      - run: npm ci
      - run: npm test
      - run: ./scripts/report-coverage.sh
      - run: npm run build
      - run: ./scripts/custom-check.sh
      - run: echo "Done"
```
Extract: `npm ci && npm test && npm run build && ./scripts/custom-check.sh`

If you see a build step with `--warnings-as-errors`, then ensure that is also run in the correct order as that acts as a linting circuit breaker.

**If CI found, STOP HERE. Use ONLY CI commands. Do NOT check project files.**

**STEP 3: Fallback to Project Files (ONLY if NO CI)**

**ONLY use this if NO CI files were found!**

1. Detect package manager from lockfile (prefer `pnpm-lock.yaml` > `yarn.lock` > `package-lock.json`) or manifest (`mix.exs`, `Cargo.toml`, etc.):
2. Find ALL scripts matching: `test`, `lint*`, `format*`, `style*`, `typecheck`, `build`

**If nothing found:**
- Report what was checked
- Ask user for the command to run
- **NEVER** guess or invent commands
</discovery-process>

<anti-rationalization>
**THESE EXCUSES NEVER APPLY**

"I know the project uses npm test"
**WRONG**: Check CI to be sure

"CI files are too complicated to parse"
**WRONG**: Extract EXACT commands anyway

"Project files are good enough"
**WRONG**: CI is ALWAYS source of truth if it exists

"I found package.json so I don't need to check CI"
**WRONG**: ALWAYS check CI FIRST

"I'll simplify the command"
**WRONG**: Use EXACT command from CI

**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST:**

☐ Checked for CI configuration (.github/workflows/*.yml, ../.github/workflows/*.yml, .gitlab-ci.yml, etc...)
☐ If CI found, extracted EXACT commands
☐ If CI found, did NOT check project files
☐ Preserved command order from CI
☐ Included setup/install commands
☐ Only checked project files if NO CI exists
☐ Did NOT modify, guess, or invent commands

**IF ANY UNCHECKED THEN EVERYTHING FAILS AT PR TIME**
</compliance-checklist>
