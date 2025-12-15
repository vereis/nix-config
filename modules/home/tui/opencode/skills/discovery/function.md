---
name: discovery/function
description: Discover function definitions, usages, and call graphs in a codebase.
---

## Purpose

Find where functions are defined, how they're used, and their dependencies before modifying or extending them.

## Discovery Process

### Step 1: Find Definition

```bash
# By exact name
rg "def $FUNCTION_NAME|function $FUNCTION_NAME|const $FUNCTION_NAME\s*="

# With context (10 lines after)
rg -A 10 "def $FUNCTION_NAME"

# In specific file types
rg "def $FUNCTION_NAME" --type ex
rg "function $FUNCTION_NAME" --type ts
```

### Step 2: Find All Usages

```bash
# Direct calls
rg "$FUNCTION_NAME\(" 

# Exclude test files
rg "$FUNCTION_NAME\(" --type-not test

# Include only test files
rg "$FUNCTION_NAME\(" -g "*_test.*" -g "*.test.*" -g "*_spec.*"

# Find imports
rg "import.*$FUNCTION_NAME|from.*import.*$FUNCTION_NAME"
rg "alias.*$FUNCTION_NAME|import.*$FUNCTION_NAME" --type ex
```

### Step 3: Trace Call Graph

**Callers (who calls this function):**
```bash
# Find all files that call this function
rg -l "$FUNCTION_NAME\("

# Get context around calls
rg -B 5 -A 2 "$FUNCTION_NAME\("
```

**Callees (what this function calls):**
```bash
# Read the function implementation
rg -A 50 "def $FUNCTION_NAME" | head -60

# Look for function calls within
```

### Step 4: Check Tests

```bash
# Find test files
rg "$FUNCTION_NAME" -g "*_test.*" -g "*.test.*" -g "*_spec.*"

# Get test context
rg -B 5 -A 20 "test.*$FUNCTION_NAME|describe.*$FUNCTION_NAME|it.*$FUNCTION_NAME"
```

Tests reveal:
- Expected inputs and outputs
- Edge cases handled
- Error conditions
- Mocking requirements

### Step 5: Document Findings

Report:
```markdown
## Function Discovery: `$FUNCTION_NAME`

### Definition
- File: `path/to/file.ex:42`
- Module: `MyApp.SomeModule`
- Arity: 2
- Signature: `def function_name(arg1, arg2)`

### Usages (N total)
- `path/to/caller1.ex:15` - [context]
- `path/to/caller2.ex:88` - [context]

### Call Graph
**Calls:**
- `other_function/1`
- `helper/2`

**Called by:**
- `parent_function/1`
- `api_handler/2`

### Test Coverage
- `path/to/test.ex:20` - Happy path
- `path/to/test.ex:35` - Edge case
- `path/to/test.ex:50` - Error handling
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"I can see the function, don't need to trace usages"
**WRONG:** Changes affect all callers

"Tests are obvious"
**WRONG:** Tests reveal edge cases you might miss

**NO EXCEPTIONS**
