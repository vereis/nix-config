---
name: debugging
description: MANDATORY for ANY bug, test failure, or unexpected behavior - four-phase systematic framework (root cause investigation, pattern analysis, hypothesis testing, implementation) that ensures understanding before attempting solutions. CONSULT THIS SKILL if you find yourself having to fix bugs, test failures, or unexpected behavior.
---

<mandatory>
**MANDATORY**: Find root cause BEFORE attempting fixes or you waste time.
**CRITICAL**: ALWAYS use this skill for ANY bug, test failure, or unexpected behavior.
**NO EXCEPTIONS**: Guessing fixes = wasted time = new bugs = broken CI.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context. DO NOT spawn additional subagents from this skill. Simply follow the debugging process and return results/fixes to the primary agent who will handle any necessary subagent delegation.
</subagent-context>

<core-principles>
1. **Find root cause BEFORE fixing** - Symptom fixes mask problems
2. **One change at a time** - Can't isolate what worked otherwise
3. **Test minimally** - Small changes reveal understanding
4. **Question architecture after 3 failures** - Not a simple bug at that point
</core-principles>

<when-to-use>
Use for ANY technical issue:
- Test failures
- Bugs in production/development
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (systematic is faster than thrashing)
</when-to-use>

<four-phases>
**You MUST complete each phase before proceeding to the next.**

## Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix, gather evidence:**

**1. Read error messages carefully**
- Read stack traces completely
- Note line numbers, file paths, error codes
- Extract EVERY piece of information

Example:
```
Error: undefined function build_query/2
  (elixir 1.14.0) lib/ecto/query.ex:123: Ecto.Query.build_query/2
  (my_app 1.0.0) lib/my_app/repo.ex:45: MyApp.Repo.get_by/2
```
Start investigation at YOUR code (line 45), not library code (line 123).

**2. Reproduce consistently**
- Can you trigger it reliably?
- What are the EXACT steps?
- Does it happen every time?
- If not reproducible: Gather more data, DON'T guess

**3. Check recent changes**
```bash
git log --oneline -20
git diff HEAD~5..HEAD
git log -p path/to/failing/file
```
Look for: new dependencies, config changes, environment differences, refactoring

**4. Gather evidence in multi-component systems**

When system has multiple components (API → Service → Database, CI → Build → Deploy):

**Add diagnostic instrumentation at EACH boundary:**
- Log what enters component
- Log what exits component
- Verify config propagation
- Check state at each layer

Run once to see WHERE it breaks, then investigate that component.

**5. Trace data flow**

When error is deep in call stack:
- Where does bad value originate?
- What called this with bad data?
- Trace UP the stack to find source
- Fix at SOURCE, not symptom

Example:
```
Error: expected string, got nil at line 100

Line 100: String.upcase(name)  # nil here
Line 90: process_user(user)
Line 80: get_user_name(user)   # returns user.name
Line 70: user = %User{name: nil}  # SOURCE

Fix at line 70, not line 100
```

**Output:** Can clearly state WHAT broke and WHY

## Phase 2: Pattern Analysis

**Find the correct pattern before attempting fixes.**

**1. Find working examples**

Locate similar WORKING code in same codebase:
```bash
rg "similar_function_name" --type elixir
rg "class.*Repository" --type python
```

**2. Compare against references**

- Read reference implementation COMPLETELY
- Check official docs, not just Stack Overflow
- Understand pattern fully before applying

**3. Identify differences**

What's different between working and broken code?
- Function signatures (arity, parameter types)
- Import/require statements
- Variable types (module vs instance)
- Data structures (map vs struct vs keyword list)
- Order of operations

**4. Understand dependencies**

- What components does pattern need?
- What config/environment variables?
- What assumptions does pattern make?

**Output:** Understand the CORRECT pattern

## Phase 3: Hypothesis Testing

**Test understanding with minimal changes.**

**1. Form specific hypothesis**

State clearly:
- "I think X is the root cause because Y"
- Be specific, not vague

Good: "Error occurs because we're passing User struct instead of User module name to Repo.get_by/2"
Bad: "Something's wrong with the database call"

**2. Test minimally**

- Make SMALLEST possible change
- Change ONE variable at a time
- Don't refactor/cleanup "while you're here"

**3. Verify results**

- Did it work? → Hypothesis CONFIRMED, proceed to Phase 4
- Didn't work? → Hypothesis REJECTED, form NEW hypothesis
- DON'T add more fixes on top of failed attempt

**4. The 3-Fix Rule**

**If 3 hypotheses fail → STOP**

This indicates architectural problem, not simple bug:
- Each fix reveals issues elsewhere
- Fixes require "massive refactoring"
- Each fix creates new symptoms

At this point:
1. Document 3 failed attempts
2. Explain what you learned from each
3. Question whether approach/architecture is sound
4. Discuss with user before continuing

**Output:** Hypothesis CONFIRMED or new hypothesis formed

## Phase 4: Implementation

**Fix the root cause with verification.**

**1. Consider writing a test (recommended, not required)**

Write test when:
- Bug is in critical path
- Bug likely to recur
- Bug involves complex logic
- Test framework already exists

Skip test when:
- Trivial typo/config fix
- One-off environmental issue
- Would require extensive setup

**2. Implement single fix**

- ONE change at a time
- Fix SOURCE, not symptom
- No "while I'm here" improvements
- No bundled refactoring

**3. Verify fix**

a) If test written, run it (should PASS)
b) Run full test suite (no regressions)
c) Manually verify original issue resolved
d) Check for side effects

**4. If fix doesn't work**

- Attempt 1 failed? → Return to Phase 1
- Attempt 2 failed? → Return to Phase 1, question assumptions
- Attempt 3 failed? → STOP, question architecture (see step 5)

**5. After 3 failed fixes: Question architecture**

Signs of architectural issues:
- Each fix reveals shared state/coupling
- Fixes require massive refactoring
- Pattern fights framework/language
- Working around design instead of with it

**Discuss with user:**
```
⚠️  ARCHITECTURAL CONCERN

I've attempted 3 fixes:
1. [Fix 1] - Failed because [reason]
2. [Fix 2] - Failed because [reason]
3. [Fix 3] - Failed because [reason]

Pattern: [each fix reveals X]

This suggests architecture might be unsound.

Recommendation: [refactoring approach or alternative]

Should we continue patching or refactor?
```

**Output:** Bug resolved, tests pass, no regressions
</four-phases>

<red-flags>
If you catch yourself thinking ANY of these, STOP and return to Phase 1:

**Skipping investigation:**
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "I don't fully understand but this might work"

**Batching changes:**
- "Fix this and refactor while I'm here"
- Multiple fixes in one attempt

**Ignoring evidence:**
- "Pattern says X but I'll adapt it"
- Proposing solutions before tracing data flow

**Architectural issues:**
- "One more fix attempt" (after 2+ failures)
- Each fix reveals new problem elsewhere
</red-flags>

<anti-rationalization>
**THESE EXCUSES NEVER APPLY**

"Issue is simple, don't need process"
**WRONG**: Simple bugs have root causes too, process is fast

"Emergency, no time for process"
**WRONG**: Systematic debugging is FASTER than thrashing

"I'll just try this quick fix first"
**WRONG**: Find root cause BEFORE attempting fixes

"I see the problem, let me fix it"
**WRONG**: Seeing symptoms ≠ understanding root cause

"Multiple fixes at once saves time"
**WRONG**: Can't isolate what worked, creates new bugs

"One more fix attempt" (after 2+ failures)
**WRONG**: 3+ failures = architectural problem

**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST:**

☐ Completed Phase 1: Root Cause Investigation
☐ Can clearly state WHAT broke and WHY
☐ Completed Phase 2: Pattern Analysis
☐ Found working examples and correct pattern
☐ Completed Phase 3: Hypothesis Testing
☐ Formed specific hypothesis, tested minimally
☐ Hypothesis CONFIRMED (or new hypothesis formed)
☐ Completed Phase 4: Implementation
☐ Implemented single fix (not multiple changes)
☐ Verified fix works (tests pass if applicable)
☐ No regressions detected
☐ If 3 fixes failed, questioned architecture

**IF ANY UNCHECKED THEN EVERYTHING FAILS**
</compliance-checklist>

<quick-reference>
| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence, trace data flow | Can state WHAT broke and WHY |
| **2. Pattern** | Find working examples, compare references, identify differences, understand dependencies | Understand CORRECT pattern |
| **3. Hypothesis** | Form specific hypothesis, test minimally, verify results | Hypothesis CONFIRMED or new one formed |
| **4. Implementation** | Consider test, implement single fix, verify completely | Bug resolved, no regressions |

**Remember:** 3 failed hypotheses = Question architecture, not just implementation
</quick-reference>
