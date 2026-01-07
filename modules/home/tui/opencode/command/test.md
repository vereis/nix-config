---
description: Run tests and fix any failures
---

Run the project's test suite:

1. Discover test command by checking:
   - package.json scripts (npm test, yarn test, pnpm test)
   - mix.exs (mix test)
   - Cargo.toml (cargo test)
   - Makefile (make test)
   - pyproject.toml / setup.py (pytest, python -m pytest)
   - go.mod (go test ./...)

2. Run tests and capture output

3. If failures:
   - Analyze error messages and stack traces
   - Identify root cause
   - Implement fix
   - Re-run tests

4. Repeat until green or report blockers that need user input
