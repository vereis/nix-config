---
name: code-quality
description: MANDATORY for code review, suggestions, and quality assessment. Defines priority order, bad smells, and review standards.
---

## Mandatory

**MANDATORY:** Use this skill when reviewing code or suggesting improvements.

**CRITICAL:** Follow priority order when making tradeoff decisions.

**NO EXCEPTIONS:** Skipping quality standards = technical debt = wasted time.

## Subagent Context

**IF YOU ARE A SUBAGENT:** Follow these standards directly and return your analysis to the primary agent.

## Priority Order

### Code Quality Priority Order

When making decisions, resolve conflicts in this order:

**1. Readability & Maintainability** (HIGHEST)
- Code is written for humans first, machine execution is by-product
- Clear intent over clever tricks
- Self-documenting over commented

**2. Correctness**
- Including edge cases and error handling
- Type safety and validation
- Concurrency safety if applicable

**3. Performance**
- Only optimize when needed
- Measure before optimizing
- Don't sacrifice readability for micro-optimizations

**4. Code Length** (LOWEST)
- Brevity is nice but not at cost of clarity
- Prefer explicit over implicit
- Don't compress logic to save lines

## Bad Smells to Watch For

Actively identify and flag these issues:

### Structural Smells
- **Repeated logic / copied code** - Extract to shared function
- **Tight coupling / circular dependencies** - Decouple modules
- **Fragile design** - Changes cascade unexpectedly to unrelated areas
- **God objects/functions** - Too many responsibilities in one place

### Clarity Smells
- **Unclear intentions** - Code doesn't reveal purpose
- **Vague naming** - Variables/functions don't describe what they do
- **Magic numbers/strings** - Unexplained constants
- **Deep nesting** - Hard to follow control flow

### Design Smells
- **Over-design** - Unnecessary complexity without actual benefits
- **Premature abstraction** - Generalizing before understanding patterns
- **Leaky abstractions** - Implementation details exposed
- **Feature envy** - Function uses another module's data excessively

### Error Handling Smells
- **Swallowed exceptions** - Errors caught but not handled
- **Missing validation** - Input not checked before use
- **Unclear error messages** - User can't understand what went wrong

## Review Structure

### Code Review Output Structure

When reviewing code, structure feedback as:

**1. Summary** (1-2 sentences)
Overall assessment of code quality

**2. Issues Found**
List with severity:
- **🔴 Critical** - Must fix before merge (bugs, security, data loss)
- **🟡 Warning** - Should fix (bad patterns, maintainability)
- **🔵 Suggestion** - Nice to have (style, minor improvements)

**3. Specific Recommendations**
For each issue:
- What's wrong
- Why it matters
- How to fix it (with example if helpful)

**4. Positive Notes** (optional)
What's done well - reinforce good patterns

## Review Checklist

**Correctness:**

☐ Logic handles expected inputs correctly

☐ Edge cases handled (null, empty, max values)

☐ Error conditions handled gracefully

☐ No obvious bugs or typos

**Maintainability:**

☐ Code is readable without extensive comments

☐ Functions/methods have single responsibility

☐ Naming is clear and consistent

☐ No unnecessary complexity

**Security:**

☐ Input is validated/sanitized

☐ No hardcoded secrets

☐ Proper authentication/authorization checks

☐ No SQL injection, XSS, etc. vulnerabilities

**Performance:**

☐ No obvious N+1 queries

☐ No unnecessary loops or allocations

☐ Appropriate data structures used

☐ No blocking operations in hot paths

**Testing:**

☐ Tests cover happy path

☐ Tests cover edge cases

☐ Tests cover error conditions

☐ Tests are readable and maintainable

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY**

"It works, so it's fine"
**WRONG:** Working code can still be bad code

"We'll refactor later"
**WRONG:** Technical debt compounds - fix now

"It's just a small change"
**WRONG:** Small changes accumulate into big problems

"Performance doesn't matter here"
**WRONG:** At least check for obvious issues

**NO EXCEPTIONS**
