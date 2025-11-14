# Project File Fallback Patterns

**ONLY use these patterns if NO CI files were found!**

If CI exists, use CI commands. These fallbacks are for projects without CI configuration.

## Node.js / JavaScript / TypeScript

**Check:** `package.json`

Look for scripts section:
```json
{
  "scripts": {
    "test": "jest",
    "lint": "eslint .",
    "build": "tsc",
    "typecheck": "tsc --noEmit"
  }
}
```

Extract commands:
- Test: `npm test` (or `yarn test`, `pnpm test`, `bun test` depending on lockfile)
- Lint: `npm run lint`
- Build: `npm run build`
- Typecheck: `npm run typecheck`

**Detect package manager:**
- `package-lock.json` → npm
- `yarn.lock` → yarn
- `pnpm-lock.yaml` → pnpm
- `bun.lockb` → bun

## Rust

**Check:** `Cargo.toml`

Standard commands:
- Test: `cargo test`
- Lint: `cargo clippy -- -D warnings`
- Build: `cargo build`
- Format check: `cargo fmt -- --check`

## Elixir

**Check:** `mix.exs`

Standard commands:
- Test: `mix test`
- Lint: `mix credo` (if credo is in deps)
- Format check: `mix format --check-formatted`
- Type check: `mix dialyzer` (if dialyzer is in deps)
- Build: `mix compile`

## Python

**Check:** `pyproject.toml`, `setup.py`, or `requirements.txt`

Common commands:
- Test: `pytest` or `python -m pytest`
- Lint: `ruff check .` or `flake8`
- Format check: `black --check .`
- Type check: `mypy .`

## Go

**Check:** `go.mod`

Standard commands:
- Test: `go test ./...`
- Lint: `golangci-lint run`
- Build: `go build ./...`
- Format check: `gofmt -l .`

## Ruby

**Check:** `Gemfile` or `Rakefile`

Look for rake tasks in Rakefile:
```ruby
task :test do
  # ...
end
```

Common commands:
- Test: `rake test` or `rspec`
- Lint: `rubocop`
- Build: `rake build`

## Make

**Check:** `Makefile`

Parse available targets:
```makefile
test:
	@echo "Running tests"

lint:
	@echo "Linting"
```

Run with: `make test`, `make lint`, `make build`

## Java / Gradle

**Check:** `build.gradle` or `build.gradle.kts`

Standard commands:
- Test: `./gradlew test`
- Lint: `./gradlew check`
- Build: `./gradlew build`

## Java / Maven

**Check:** `pom.xml`

Standard commands:
- Test: `mvn test`
- Build: `mvn compile`
- Package: `mvn package`

## Detection Priority

1. Look for lockfiles/manifests
2. Read configuration files for script definitions
3. Use language-standard commands if no custom scripts defined
4. Ask user if unclear which commands to run

## When Nothing Found

If no CI and no recognizable project files:
- Report what was checked
- Ask user for the command to run
- Don't guess or invent commands
