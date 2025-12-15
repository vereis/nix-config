---
name: discovery/test
description: Discover test patterns, fixtures, and mocking strategies in a codebase.
---

## Purpose

Find and understand testing patterns before writing new tests, ensuring consistency and proper coverage.

## Discovery Process

### Step 1: Find Test Framework

```bash
# Check package files
cat package.json 2>/dev/null | grep -E "jest|mocha|vitest|cypress"
cat mix.exs 2>/dev/null | grep -E "ex_unit|mox|bypass"
cat Cargo.toml 2>/dev/null | grep -E "\[dev-dependencies\]" -A 10

# Check for test configs
ls -la jest.config.* vitest.config.* pytest.ini conftest.py
```

### Step 2: Find Test File Patterns

```bash
# Locate test directories
find . -type d -name "test*" -o -name "*spec*" -o -name "__tests__" 2>/dev/null

# Find test files
find . -name "*_test.*" -o -name "*.test.*" -o -name "*_spec.*" 2>/dev/null | head -20

# Check test file structure
ls -la test/ tests/ spec/ __tests__/ 2>/dev/null
```

### Step 3: Analyze Test Structure

```bash
# Find describe/context blocks
rg "describe|context|test |it " -g "*_test.*" -g "*.test.*" | head -30

# Find setup/teardown
rg "setup|before|after|beforeEach|afterEach" -g "*_test.*" | head -20

# Find assertions
rg "assert|expect|should" -g "*_test.*" | head -20
```

### Step 4: Find Fixtures and Factories

```bash
# Look for fixture directories
ls -la test/fixtures/ test/support/ spec/fixtures/ spec/support/ 2>/dev/null

# Find factory files
find . -name "*factory*" -o -name "*fixture*" 2>/dev/null

# Check for factory patterns
rg "factory|fixture|build\(|create\(" -g "*_test.*" | head -20
```

### Step 5: Find Mocking Patterns

```bash
# Mock/stub patterns
rg "mock|stub|spy|fake|double" -g "*_test.*" | head -20

# Specific mock libraries
rg "jest\.mock|sinon|Mox\.|Bypass\." | head -20

# HTTP mocking
rg "nock|msw|bypass|mock_server" | head -20
```

### Step 6: Document Findings

Report:
```markdown
## Test Discovery

### Framework
- **Unit tests**: ExUnit / Jest / pytest
- **Integration tests**: [framework]
- **E2E tests**: Cypress / Playwright

### File Structure
```
test/
├── unit/           # Unit tests
├── integration/    # Integration tests
├── support/        # Helpers and fixtures
└── fixtures/       # Test data
```

### Naming Conventions
- Test files: `*_test.exs` / `*.test.ts`
- Test names: `test "description"` / `it("should...")`

### Setup Patterns
```elixir
setup do
  user = insert(:user)
  {:ok, user: user}
end
```

### Assertion Style
- `assert result == expected`
- `expect(result).toBe(expected)`

### Mocking Strategy
- **External APIs**: Bypass / nock
- **Modules**: Mox / jest.mock
- **Time**: Timecop / jest.useFakeTimers

### Factory/Fixture Pattern
```elixir
# Using ExMachina
insert(:user, name: "Test User")
build(:order, status: :pending)
```
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"I know how to write tests"
**WRONG:** Match existing test patterns

"Tests are straightforward"
**WRONG:** Discover mocking and fixture patterns first

**NO EXCEPTIONS**
