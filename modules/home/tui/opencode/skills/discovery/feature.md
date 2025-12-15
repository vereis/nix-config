---
name: discovery/feature
description: Discover how features are implemented in a codebase - patterns, conventions, architecture.
---

## Purpose

Find existing implementations of features to understand patterns, conventions, and architecture before implementing similar features.

## Discovery Process

### Step 1: Identify Feature Type

What kind of feature are you looking for?

| Type | Examples |
|------|----------|
| **UI Component** | React/Vue components, forms, modals |
| **API Endpoint** | REST handlers, GraphQL resolvers |
| **Business Logic** | Domain services, use cases, workflows |
| **Data Model** | Database schemas, types, entities |
| **Integration** | External APIs, webhooks, message queues |
| **Background Job** | Workers, schedulers, async tasks |

### Step 2: Search Patterns

**For UI Components:**
```bash
# React/TypeScript
rg -l "function.*ComponentName|const.*ComponentName" --type tsx --type jsx
rg -l "export.*ComponentName" src/components/

# Vue
rg -l "name:.*ComponentName" --type vue
```

**For API Endpoints:**
```bash
# Express/Node
rg "router\.(get|post|put|delete|patch)" --type ts --type js

# Python/Flask/FastAPI
rg "def.*endpoint|@app\.(get|post)|@router\." --type py

# Elixir/Phoenix
rg "get|post|put|delete|patch.*do" --type ex
rg "scope.*do" lib/*_web/router.ex
```

**For Business Logic:**
```bash
# Services/Use Cases
rg "class.*Service|module.*Service" 
rg "def.*use_case|class.*UseCase"
rg "defmodule.*Context" --type ex
```

**For Data Models:**
```bash
# Schemas/Models
rg "schema|model|entity" 
rg "defmodule.*Schema" --type ex
rg "class.*Model" --type py
```

**For Background Jobs:**
```bash
rg "Worker|Job|Task" 
rg "perform|execute|run" lib/**/workers/
```

### Step 3: Analyze Found Implementations

For each found implementation:

1. **Read completely** - Don't skim, understand the full flow
2. **Note patterns:**
   - Naming conventions (files, functions, variables)
   - Directory structure
   - Import/dependency patterns
   - Error handling approach
3. **Check tests** - They show expected behavior and edge cases
4. **Find related files:**
   - Types/interfaces
   - Tests
   - Configs
   - Documentation

### Step 4: Document Findings

Report:
```markdown
## Feature Discovery: [Feature Name]

### File Locations
- Main implementation: `path/to/file.ex:line`
- Tests: `path/to/test.ex`
- Types: `path/to/types.ex`

### Naming Conventions
- Files: `snake_case.ex`
- Modules: `PascalCase`
- Functions: `snake_case`

### Architectural Patterns
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

### Dependencies
- [Dependency 1]: [Purpose]
- [Dependency 2]: [Purpose]

### Test Patterns
- [How tests are structured]
- [Mocking approach]
```

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"I know how this project works"
**WRONG:** Search to confirm assumptions

"Similar to other projects I've seen"
**WRONG:** Every project has unique patterns

"I'll figure it out as I go"
**WRONG:** Discover patterns FIRST

**NO EXCEPTIONS**
