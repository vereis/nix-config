---
name: refactoring
description: "**MANDATORY**: Load when refactoring code. Comprehensive refactoring checklist for cleaner, more maintainable code"
---

# Code Refactoring Checklist

## Research First

Before making refactoring recommendations, use the general subagent to research best practices for what the user is trying to do. This is especially important for:

- Language-specific idioms and conventions
- Library/framework patterns the code is using
- Common refactoring patterns for the type of code being changed

For complex changes spanning multiple concerns, spin up multiple subagents in parallel to research each area independently. Don't guess at best practices - verify them.

## Language-Specific Guidance

Some languages have additional refactoring guidance. Check for and read the relevant file if working with:

- **Elixir**: Read `elixir.md` in this skill directory

## Dead Code & Unused Abstractions

- Unused imports, functions, variables, parameters
- Unreachable code paths
- Commented-out code - delete it, version control exists
- Interfaces/base classes with only one implementation
- "Future-proofing" abstractions that never got used

## Inlining Candidates (High Priority)

**Default to inlining private functions.** Only extract when there's a genuine reason.

Inline when:
- Function is only called once
- Function body is short and clear
- The function name doesn't add more clarity than the code itself
- You have to jump through multiple calls to understand simple flow
- The extraction was done for "clean code" reasons rather than practical ones

Keep extracted when:
- Reused in multiple places
- Library/API convention demands it
- The extraction genuinely clarifies complex logic
- Testing requires it (but question whether you're testing the right thing)

**Rule of thumb**: If reading the abstraction requires more mental effort than reading the inline code would, inline it.

## Polymorphism Audit

Prefer operation-primal (switches/enums) over operand-primal (inheritance) by default.

Ask:
- Do types actually vary at runtime, or is this compile-time known?
- Are you adding types more often, or operations? (Structure should match)
- Would a discriminated union/enum + switch be simpler?
- Is the inheritance preventing compiler optimization in a hot path?
- Could this be a simple function with a type parameter instead of a class hierarchy?

Inheritance hierarchies impose constraints and prevent optimization. Use them only when runtime type variation is genuinely needed AND types change more often than operations.

## Comment Quality

Delete:
- Comments restating what code does (`# increment counter` above `counter += 1`)
- Obvious operation descriptions
- Stale TODOs nobody will address
- Changelog comments (use git blame)
- Section dividers (use file structure instead)

Keep/Add:
- *Why* this approach was taken (especially if non-obvious)
- Workarounds with links to issues/bugs
- Non-obvious side effects
- Performance decisions
- External constraints (API quirks, spec requirements)

## Unit Test Audit

If NO tests exist:
- Add tests that verify *behavior*, not implementation details
- Focus on public interfaces, not private internals
- Test edge cases and error paths
- Don't test trivial stuff - test logic that could actually break

If tests exist:
- Do they test behavior or implementation? (Tests that break on refactoring are testing the wrong thing)
- Over-mocked? (If you mock everything, you're testing nothing)
- Flaky? (Delete or fix - flaky tests erode trust)
- Actually useful? (Would a bug here be caught?)

## Performance Awareness

Consider:
- Is this code in a hot path? (nanoseconds matter vs milliseconds are fine)
- Are abstractions preventing compiler optimization where it matters?
- Is there unnecessary indirection where direct calls would work?
- Are you paying for polymorphism you don't need?

Don't prematurely optimize, but don't prematurely abstract either. Abstractions have cost.

## Quick Process Reference

1. Understand the code before changing it
2. Verify test coverage exists (or add it first)
3. Small steps - each refactoring should be independently functional
4. Run tests after each change
5. Don't mix refactoring with feature changes

## Report Format

Organize findings by impact:

- **High**: Dead code, inlining opportunities, unnecessary polymorphism, missing critical tests
- **Medium**: Comment cleanup, test quality issues, minor over-abstraction
- **Low**: Naming tweaks, style consistency

For each finding, provide:

1. **Location**: File path and line range
2. **Current code**: Show the relevant snippet (not entire modules, just enough context)
3. **Issue**: What's wrong
4. **Recommendation**: What to change (with example if helpful)
5. **Rationale**: Why this matters (brief)

Example:

```
### High: Inline single-use private function

**Location**: `src/auth/login.ts:45-52`

**Current code**:
    function validateEmail(email: string): boolean {
      return email.includes('@') && email.includes('.');
    }

    // Only called once, 10 lines below:
    if (!validateEmail(userInput.email)) { ... }

**Issue**: Single-use private function adds indirection without clarity benefit.

**Recommendation**: Inline the validation logic at the call site.

**Rationale**: The function name doesn't explain more than the code itself does.
```

## After Reporting

After presenting all findings, ask the user:

> "Would you like me to implement these refactors? I’ll do them as atomic commits, running tests/linting after each one."

If the user agrees:
1. List each refactor as a numbered checklist
2. Implement one refactor at a time
3. Run tests and linting after each change
4. Commit atomically after each successful refactor
