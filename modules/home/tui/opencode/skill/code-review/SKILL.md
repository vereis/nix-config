---
name: code-review
description: Code review checklist and process
---

# Code Review Checklist

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
