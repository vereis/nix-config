---
name: code-review
description: "**MANDATORY**: Load when reviewing code changes. Comprehensive code review checklist and process"
---

# Code Review Checklist

**MANDATORY**: Use the general subagent to research common patterns and best practices for similar implementations.

## Architecture
- [ ] Design patterns appropriate for the problem
- [ ] Proper separation of concerns
- [ ] Component boundaries well-defined
- [ ] No tight coupling between modules
- [ ] Follows project architectural conventions
- [ ] **Research**: Use general subagent to find common patterns for this type of implementation

## Dead Code Detection
- [ ] No unused imports or dependencies
- [ ] No unreachable code paths
- [ ] No commented-out code (unless temporarily needed with explanation)
- [ ] All functions/methods are actually called
- [ ] No unused variables or parameters

## Comments & Documentation
- [ ] Comments reserved for complex/non-obvious logic
- [ ] **NEVER** comment code that merely duplicates what code literally does
  - ❌ BAD: `// Increment counter` above `counter++`
  - ✅ GOOD: `// Skip cached entries to force fresh data fetch` above complex logic
- [ ] Complex algorithms have explanatory comments about *why*, not *what*
- [ ] Public APIs have appropriate documentation
- [ ] Hard-to-follow code has helpful context

## Security
- [ ] Input validation on all user inputs
- [ ] No hardcoded secrets or API keys
- [ ] Proper authentication/authorization checks
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Sensitive data properly encrypted/hashed

## Performance
- [ ] No obvious N+1 queries
- [ ] No unnecessary loops or allocations
- [ ] Appropriate data structures used
- [ ] No blocking operations in hot paths
- [ ] Proper pagination for large datasets

## Maintainability
- [ ] Clear, descriptive naming
- [ ] Functions have single responsibility
- [ ] No unnecessary complexity
- [ ] No duplicated code
- [ ] Proper error messages
- [ ] Code is self-documenting

## Correctness
- [ ] Edge cases handled (null, empty, max values)
- [ ] Error conditions handled gracefully
- [ ] No obvious bugs or typos
- [ ] Logic matches requirements
- [ ] Boundary conditions correct

## Testing
- [ ] Tests cover happy path
- [ ] Tests cover edge cases
- [ ] Tests cover error conditions
- [ ] Tests are readable and maintainable
- [ ] No flaky tests

## Report Format

Report issues by severity:
- 🔴 **Critical**: Must fix (bugs, security, data loss)
- 🟡 **Warning**: Should fix (bad patterns, maintainability)
- 🔵 **Suggestion**: Nice to have (style, minor improvements)

Include specific fix recommendations with code examples.

## Comment Tone

**Be direct and concise** - avoid over-explaining or corporate language:
- ❌ BAD: "Your PR description says X but the tests do Y. This means: 1) tests don't reproduce the bug 2) fix won't be validated 3) future regressions possible. Fix needed: update mocks to match..."
- ✅ GOOD: "The test mocks don't match the production data format you described. Add unit tests to validate the fix and prevent future regressions."

Trust the developer to understand implications - just point out the issue and suggest the fix.
