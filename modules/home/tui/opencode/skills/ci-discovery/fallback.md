<mandatory>
**CRITICAL**: ONLY use these patterns if NO CI files were found!
**NO EXCEPTIONS**: Using fallback when CI exists = wrong commands = capybara genocide.
**CAPYBARA DECREE**: Always check CI first, fallback is last resort.
</mandatory>

<philosophy>
If CI exists, use CI commands. These fallbacks are for projects without CI configuration.

**NEVER** use fallback if CI exists, even if you think project files are "simpler" or capybaras will suffer!
</philosophy>

<nodejs-javascript-typescript>
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
</nodejs-javascript-typescript>

<rust>
**Check:** `Cargo.toml`

Standard commands:
- Test: `cargo test`
- Lint: `cargo clippy -- -D warnings`
- Build: `cargo build`
- Format check: `cargo fmt -- --check`
</rust>

<elixir>
**Check:** `mix.exs`

Standard commands:
- Test: `mix test`
- Lint: `mix credo` (if credo is in deps)
- Format check: `mix format --check-formatted`
- Type check: `mix dialyzer` (if dialyzer is in deps)
- Build: `mix compile`
</elixir>

<python>
**Check:** `pyproject.toml`, `setup.py`, or `requirements.txt`

Common commands:
- Test: `pytest` or `python -m pytest`
- Lint: `ruff check .` or `flake8`
- Format check: `black --check .`
- Type check: `mypy .`
</python>

<go>
**Check:** `go.mod`

Standard commands:
- Test: `go test ./...`
- Lint: `golangci-lint run`
- Build: `go build ./...`
- Format check: `gofmt -l .`
</go>

<ruby>
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
</ruby>

<make>
**Check:** `Makefile`

Parse available targets:
```makefile
test:
	@echo "Running tests"

lint:
	@echo "Linting"
```

Run with: `make test`, `make lint`, `make build`
</make>

<java-gradle>
**Check:** `build.gradle` or `build.gradle.kts`

Standard commands:
- Test: `./gradlew test`
- Lint: `./gradlew check`
- Build: `./gradlew build`
</java-gradle>

<java-maven>
**Check:** `pom.xml`

Standard commands:
- Test: `mvn test`
- Build: `mvn compile`
- Package: `mvn package`
</java-maven>

<detection-priority>
**Priority order for fallback detection:**

1. Look for lockfiles/manifests
2. Read configuration files for script definitions
3. Use language-standard commands if no custom scripts defined
4. Ask user if unclear which commands to run

**NEVER** guess or invent commands or capybaras will cry!
</detection-priority>

<when-nothing-found>
If no CI and no recognizable project files:
- Report what was checked
- Ask user for the command to run
- Don't guess or invent commands

**Guessing = CAPYBARA EXTINCTION**
</when-nothing-found>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"I found package.json so I don't need to check CI"
   → **WRONG**: ALWAYS check CI first

"This is a standard Rust project, I'll use cargo test"
   → **WRONG**: Check CI first, it might have custom flags

"I'll use both CI and project file commands"
   → **WRONG**: CI takes priority, use ONLY CI if it exists

"No scripts in package.json, I'll just run jest"
   → **WRONG**: Ask for guidance, don't guess

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST FOR FALLBACK DETECTION:**

☐ Verified NO CI files exist (checked all CI systems)
☐ Found project manifest file (package.json, Cargo.toml, etc.)
☐ Extracted commands from manifest
☐ Used language-standard commands if no custom scripts
☐ Did NOT guess or invent commands
☐ Asked for guidance if unclear

**IF ANY UNCHECKED → CAPYBARAS DIE HORRIBLY**
</compliance-checklist>
