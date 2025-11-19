<mandatory>
**CRITICAL**: Extract EXACT commands from CI, don't modify or infer.
**NO EXCEPTIONS**: Changed commands = CI mismatch = capybara extinction.
**CAPYBARA DECREE**: Preserve order, include setup, use exact syntax.
</mandatory>

<purpose>
Once you've found CI files, extract the EXACT commands they run. Don't modify or infer - use what CI uses or capybaras will cry!
</purpose>

<command-types>
**Look for these command types:**

- **Test commands**: `npm test`, `mix test`, `cargo test`, `pytest`, `go test`, `make test`
- **Lint commands**: `npm run lint`, `eslint`, `mix format --check-formatted`, `cargo clippy`, `ruff check`
- **Build commands**: `npm run build`, `mix compile`, `cargo build`, `make build`
- **Typecheck commands**: `tsc --noEmit`, `mypy`, `dialyzer`
</command-types>

<github-actions>
Look for `jobs.<job_id>.steps[].run` commands:

```yaml
jobs:
  test:
    steps:
      - run: npm ci
      - run: npm test
      - run: npm run build
```

Extract: `npm ci && npm test && npm run build`

**Common job names to check:**
- `test`, `tests`, `unit-test`, `integration-test`
- `lint`, `format`, `style`
- `build`, `compile`
- `typecheck`, `type-check`
</github-actions>

<gitlab-ci>
Look for job scripts:

```yaml
test:
  script:
    - mix deps.get
    - mix test
```

Extract: `mix deps.get && mix test`
</gitlab-ci>

<circleci>
Look for job steps with `run` commands:

```yaml
jobs:
  test:
    steps:
      - run: cargo test
      - run: cargo clippy
```

Extract: `cargo test && cargo clippy`
</circleci>

<other-ci-systems>
**Travis CI** - Check `script:` section
**Buildkite** - Check `command:` in pipeline steps
**Jenkins** - Look for `sh` or `script` blocks in stages
</other-ci-systems>

<important-patterns>
**Install + Run Pattern**

If CI runs install then test:
```yaml
- run: npm ci
- run: npm test
```

Use both: `npm ci && npm test`

**Multiple Test Commands**

If CI runs multiple test types:
```yaml
- run: npm run test:unit
- run: npm run test:integration
```

You need both: `npm run test:unit && npm run test:integration`

**Conditional Commands**

If commands only run on certain branches/conditions, use the default (usually main/master branch) commands.
</important-patterns>

<extraction-rules>
**MANDATORY rules for extracting commands:**

1. **Preserve order** - Run commands in the same order as CI
2. **Include setup** - If CI runs `npm ci` before `npm test`, include both
3. **Combine with &&** - Chain commands that CI runs sequentially
4. **Ignore non-quality steps** - Skip deploy, notify, artifact upload steps
5. **Use exact syntax** - `npm test` vs `npm run test` matters, match CI exactly

**Breaking these rules = CAPYBARA GENOCIDE**
</extraction-rules>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"The install step isn't necessary locally"
   → **WRONG**: Include ALL steps CI runs

"I'll simplify the command"
   → **WRONG**: Use EXACT command from CI

"I'll combine these into one command"
   → **WRONG**: Only combine with && if CI runs them sequentially

"I'll skip the setup commands"
   → **WRONG**: Include setup if CI includes it

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST WHEN EXTRACTING COMMANDS:**

☐ Found relevant job/step in CI file
☐ Extracted commands in EXACT order
☐ Included setup/install commands
☐ Combined sequential commands with &&
☐ Did NOT modify syntax or flags
☐ Did NOT skip any commands
☐ Ignored only non-quality steps (deploy, notify)

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
</compliance-checklist>
