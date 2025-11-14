# Extracting Commands from CI Configurations

Once you've found CI files, extract the EXACT commands they run. Don't modify or infer - use what CI uses.

## Command Types to Look For

- **Test commands**: `npm test`, `mix test`, `cargo test`, `pytest`, `go test`, `make test`
- **Lint commands**: `npm run lint`, `eslint`, `mix format --check-formatted`, `cargo clippy`, `ruff check`
- **Build commands**: `npm run build`, `mix compile`, `cargo build`, `make build`
- **Typecheck commands**: `tsc --noEmit`, `mypy`, `dialyzer`

## GitHub Actions

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

## GitLab CI

Look for job scripts:

```yaml
test:
  script:
    - mix deps.get
    - mix test
```

Extract: `mix deps.get && mix test`

## CircleCI

Look for job steps with `run` commands:

```yaml
jobs:
  test:
    steps:
      - run: cargo test
      - run: cargo clippy
```

Extract: `cargo test && cargo clippy`

## Other CI Systems

**Travis CI** - Check `script:` section
**Buildkite** - Check `command:` in pipeline steps
**Jenkins** - Look for `sh` or `script` blocks in stages

## Important Patterns

### Install + Run Pattern

If CI runs install then test:
```yaml
- run: npm ci
- run: npm test
```

Use both: `npm ci && npm test`

### Multiple Test Commands

If CI runs multiple test types:
```yaml
- run: npm run test:unit
- run: npm run test:integration
```

You need both: `npm run test:unit && npm run test:integration`

### Conditional Commands

If commands only run on certain branches/conditions, use the default (usually main/master branch) commands.

## Extraction Rules

1. **Preserve order** - Run commands in the same order as CI
2. **Include setup** - If CI runs `npm ci` before `npm test`, include both
3. **Combine with &&** - Chain commands that CI runs sequentially
4. **Ignore non-quality steps** - Skip deploy, notify, artifact upload steps
5. **Use exact syntax** - `npm test` vs `npm run test` matters, match CI exactly
