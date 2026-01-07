---
name: planning
description: Planning process for complex tasks
---

# Planning Process

## When to Plan

- Complex features requiring multiple files
- Refactoring with unclear scope
- Bug fixes needing investigation
- Any task where "just start coding" is premature

## Planning Steps

### 1. Understand
- What is the goal?
- What are the requirements?
- What are the constraints?
- Ask clarifying questions if unclear

### 2. Research
- Explore the codebase
- Find similar implementations
- Identify patterns and conventions
- Note dependencies

### 3. Design
- Identify approach
- Consider alternatives
- Evaluate tradeoffs
- Choose best option

### 4. Break Down
- Create atomic implementation steps
- Order by dependencies (backend-first)
- Each step should be testable

### 5. Document
- Save plan to `.opencode/plans/YYYY-MM-DD-<topic>.md`
- Include all details needed for implementation

### 6. Present
- Show plan to user
- Get approval before implementation

## Plan File Format

```markdown
# Plan: <topic>
Date: YYYY-MM-DD

## Summary
Brief description of what we're building/fixing.

## Requirements
- Requirement 1
- Requirement 2

## Approach
Description of the chosen approach and why.

## Alternatives Considered
- Alternative 1: Why not chosen
- Alternative 2: Why not chosen

## Implementation Steps
1. [ ] Step 1
2. [ ] Step 2
3. [ ] Step 3

## Files Affected
- path/to/file1.ext
- path/to/file2.ext

## Risks/Considerations
- Risk 1
- Risk 2

## Testing Strategy
How to verify the implementation works.
```

## Backend-First Ordering

When breaking down tasks, order by layer:
1. Database/Schema
2. Models/Types
3. Business Logic
4. API/Interface
5. Frontend/UI
