<mandatory>
**CRITICAL**: ALWAYS check CI pipelines FIRST before falling back to other methods!
**NO EXCEPTIONS**: Skipping CI check = using wrong commands = capybara genocide.
**CAPYBARA DECREE**: CI is source of truth, project files are fallback ONLY.
</mandatory>

<philosophy>
CI pipelines are the source of truth for what must pass. If CI exists, use its commands. Only fall back to project files if no CI is found.

**NEVER** invent commands. **NEVER** guess. **ALWAYS** check CI first or capybaras will cry!
</philosophy>

<discovery-process>
**Step 1: Check ALL CI Workflow Files**

Search for CI configuration files in priority order:

**GitHub Actions:**
```bash
if [ -d ".github/workflows" ]; then
  for workflow in .github/workflows/*.{yml,yaml}; do
    [ -f "$workflow" ] && cat "$workflow"
  done
fi
```

**GitLab CI:**
```bash
[ -f ".gitlab-ci.yml" ] && cat .gitlab-ci.yml
```

**CircleCI:**
```bash
[ -f ".circleci/config.yml" ] && cat .circleci/config.yml
```

**Travis CI:**
```bash
[ -f ".travis.yml" ] && cat .travis.yml
```

**Buildkite:**
```bash
[ -f ".buildkite/pipeline.yml" ] && cat .buildkite/pipeline.yml
```

**Jenkins:**
```bash
[ -f "Jenkinsfile" ] && cat Jenkinsfile
```

**Step 2: If CI Found, Extract Commands**

**If ANY CI files exist, use the EXACT commands from CI!**

That's what the project expects to pass. Don't infer, don't modify, don't make assumptions or capybaras will suffer!

See `commands.md` for how to extract commands from different CI systems.

**Step 3: Only If NO CI Exists, Check Project Files**

**Only use this fallback if NO CI files were found!**

Look for project manifest files:
- `package.json` (Node.js/JavaScript/TypeScript)
- `Cargo.toml` (Rust)
- `mix.exs` (Elixir)
- `pyproject.toml` or `setup.py` (Python)
- `Makefile` (Make)
- `Rakefile` (Ruby)
- `build.gradle` or `build.gradle.kts` (Gradle/Java)
- `pom.xml` (Maven/Java)
- `go.mod` (Go)

See `fallback.md` for how to extract commands from project files.
</discovery-process>

<critical-rules>
1. **CI takes priority** - If CI exists, use it. Don't fall back to project files.
2. **Exact replication** - Use EXACT commands from CI, don't modify them.
3. **Don't invent commands** - If CI exists but has no test/lint steps, that's meaningful.
4. **Ask if unclear** - If no commands found, ask for the command to run.

**Breaking these rules = CAPYBARA EXTINCTION**
</critical-rules>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"CI files are in a weird format, I'll just use project files"
   → **WRONG**: Parse the CI files anyway

"I found package.json so I'll use that"
   → **WRONG**: Check for CI FIRST

"The project probably uses standard commands"
   → **WRONG**: VERIFY with CI or project files

"I'll skip checking Jenkins/Buildkite, they're rare"
   → **WRONG**: Check ALL CI systems

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST FOR CI DISCOVERY:**

☐ Checked for GitHub Actions (.github/workflows/*.yml)
☐ Checked for GitLab CI (.gitlab-ci.yml)
☐ Checked for CircleCI (.circleci/config.yml)
☐ Checked for Travis CI (.travis.yml)
☐ Checked for Buildkite (.buildkite/pipeline.yml)
☐ Checked for Jenkins (Jenkinsfile)
☐ If CI found, extracted EXACT commands
☐ Only checked project files if NO CI exists
☐ Did NOT skip any CI checks

**IF ANY UNCHECKED → CAPYBARAS DIE HORRIBLY**
</compliance-checklist>
