---
name: discovery/pattern
description: Discover coding patterns, conventions, and style guides in a codebase.
---

## Purpose

Find and understand coding patterns and conventions before writing new code, ensuring consistency with existing codebase.

## Discovery Process

### Step 1: Check for Style Guides

```bash
# Look for documentation
ls -la docs/ README.md CONTRIBUTING.md STYLE.md .editorconfig

# Check for linter configs
ls -la .eslintrc* .prettierrc* .rubocop.yml .credo.exs pyproject.toml

# Check for formatter configs
cat .prettierrc 2>/dev/null || cat .editorconfig 2>/dev/null
```

### Step 2: Analyze Existing Code

**Naming Conventions:**
```bash
# File naming
ls -la src/ lib/ app/

# Function naming patterns
rg "^def |^function |^const " --type ex --type ts | head -20

# Variable naming
rg "let |const |var " --type ts | head -20
```

**Import/Module Patterns:**
```bash
# Import style
rg "^import |^from " --type ts | head -20
rg "^alias |^import |^require " --type ex | head -20

# Module organization
tree -L 2 src/ lib/ app/ 2>/dev/null
```

**Error Handling:**
```bash
# Try/catch patterns
rg "try|catch|rescue|raise|throw" | head -20

# Result/Either patterns
rg "Ok\(|Err\(|{:ok|{:error" | head -20
```

### Step 3: Identify Common Patterns

Look for:
- **Repository pattern** - Data access abstraction
- **Service pattern** - Business logic encapsulation
- **Factory pattern** - Object creation
- **Strategy pattern** - Interchangeable algorithms
- **Observer pattern** - Event handling
- **Middleware pattern** - Request/response processing

### Step 4: Document Findings

Report:
```markdown
## Pattern Discovery

### Naming Conventions
- Files: `snake_case.ex` / `PascalCase.tsx`
- Functions: `snake_case` / `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Types: `PascalCase`

### Directory Structure
```
lib/
├── my_app/           # Business logic
├── my_app_web/       # Web layer
└── my_app/contexts/  # Domain contexts
```

### Common Patterns
- **Data Access**: Repository pattern via Ecto
- **Business Logic**: Context modules
- **Error Handling**: `{:ok, result}` / `{:error, reason}` tuples

### Import Conventions
- Group by: stdlib, deps, local
- Sort: alphabetically within groups

### Testing Conventions
- File naming: `*_test.exs`
- Setup: `setup` blocks for fixtures
- Assertions: `assert` / `refute`
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"I'll use my preferred style"
**WRONG:** Match existing codebase conventions

"Patterns are obvious"
**WRONG:** Discover and document explicitly

**NO EXCEPTIONS**
