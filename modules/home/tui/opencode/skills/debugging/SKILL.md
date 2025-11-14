---
name: debugging
description: Use when encountering ANY bug, test failure, or unexpected behavior, before proposing fixes - four-phase systematic framework (root cause investigation, pattern analysis, hypothesis testing, implementation) that ensures understanding before attempting solutions
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Non-Negotiable Rule

**Find the root cause BEFORE proposing any fixes.**

If you haven't completed Phase 1 (Root Cause Investigation), you cannot suggest solutions. No exceptions.

This isn't optional - debugging without understanding WHY something broke leads to:
- Wasted time on wrong fixes
- New bugs introduced
- Symptoms masked instead of problems solved
- Multiple failed fix attempts

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Need quick fix NOW (systematic is faster than thrashing)

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix, gather evidence systematically:**

#### 1. Read Error Messages Carefully

- Don't skip past errors or warnings
- They often contain the exact solution
- Read stack traces completely
- Note line numbers, file paths, error codes
- Extract EVERY piece of information

**Example:**
```
Error: undefined function build_query/2
  (elixir 1.14.0) lib/ecto/query.ex:123: Ecto.Query.build_query/2
  (my_app 1.0.0) lib/my_app/repo.ex:45: MyApp.Repo.get_by/2
```

From this you know:
- Function name wrong: `build_query/2` doesn't exist
- Location in YOUR code: `lib/my_app/repo.ex:45`
- Library involved: Ecto
- Start investigation at line 45, not line 123

#### 2. Reproduce Consistently

- Can you trigger it reliably?
- What are the EXACT steps?
- Does it happen every time?
- **If not reproducible:** Gather more data, DON'T guess

**Example:**
```bash
# Reliable reproduction:
1. Start app: mix phx.server
2. Navigate to /users/123
3. Click "Edit Profile"
4. Error appears in console

# Happens: Always
# Environment: Development only (not production)
```

#### 3. Check Recent Changes

What changed that could cause this?

```bash
# Check recent commits
git log --oneline -20

# Check what actually changed
git diff HEAD~5..HEAD

# Check specific files mentioned in error
git log -p lib/my_app/repo.ex
```

Look for:
- New dependencies added
- Config changes
- Environmental differences
- Refactoring that might have broken something

#### 4. Gather Evidence in Multi-Component Systems

**When system has multiple components** (CI → build → deploy, API → service → database):

**BEFORE proposing fixes, add diagnostic instrumentation:**

For EACH component boundary:
- Log what data enters component
- Log what data exits component  
- Verify environment/config propagation
- Check state at each layer

**Then:**
1. Run once to gather evidence showing WHERE it breaks
2. Analyze evidence to identify failing component
3. Investigate that specific component

**Example (API → Service → Database):**
```elixir
# Layer 1: Controller (API entry point)
def update(conn, params) do
  Logger.info("Controller received params: #{inspect(params)}")
  case UserService.update_profile(params) do
    {:ok, user} -> 
      Logger.info("Controller: success, user=#{inspect(user)}")
      # ...
    {:error, reason} ->
      Logger.error("Controller: failed, reason=#{inspect(reason)}")
      # ...
  end
end

# Layer 2: Service (business logic)
def update_profile(params) do
  Logger.info("Service received params: #{inspect(params)}")
  changeset = User.changeset(%User{}, params)
  Logger.info("Service changeset valid? #{changeset.valid?}")
  
  case Repo.update(changeset) do
    {:ok, user} ->
      Logger.info("Service: DB update succeeded")
      {:ok, user}
    {:error, changeset} ->
      Logger.error("Service: DB update failed, errors=#{inspect(changeset.errors)}")
      {:error, changeset}
  end
end

# Layer 3: Database (via Repo)
# Ecto already logs queries, check logs
```

**This reveals:** Which layer fails (controller ✓ → service ✓ → database ✗)

#### 5. Trace Data Flow

**When error is deep in call stack:**

- Where does the bad value originate?
- What called this function with bad data?
- Keep tracing UP the call stack until you find the source
- Fix at the SOURCE, not at the symptom

**Example:**
```
Error: expected string, got nil at line 100

Line 100: String.upcase(name)  # nil here

Trace backwards:
- Line 90 called: process_user(user)
- Line 80 called: get_user_name(user)  # returns user.name
- Line 70: user = %User{name: nil}  # SOURCE: nil created here

Fix at line 70 (source), not line 100 (symptom)
```

#### Output of Phase 1

After completing investigation, document:

```
ROOT CAUSE ANALYSIS:

Error: [exact error message]
Location: [file:line where YOUR code triggers it]
Reproduction: [exact steps to reproduce]
Recent changes: [commits/changes that could cause this]
Evidence: [diagnostic output showing WHERE it fails]
Root cause: [the actual underlying problem]
```

**Only proceed to Phase 2 after you can clearly state the root cause.**

### Phase 2: Pattern Analysis

**Goal:** Find the pattern before attempting fixes.

Once you understand the root cause, understand the CORRECT pattern before implementing a fix.

#### 1. Find Working Examples

Locate similar WORKING code in the same codebase:
- What works that's similar to what's broken?
- How do other parts of the codebase handle this pattern?

```bash
# Search for similar patterns
rg "similar_function_name" --type elixir
rg "class.*Repository" --type python
rg "async.*fetch" --type typescript
```

**Example:**
```
Looking for: How to properly call Repo.get_by/2

Found working examples:
- lib/my_app/accounts.ex:23 - Uses Repo.get_by(User, email: email)
- lib/my_app/posts.ex:45 - Uses Repo.get_by(Post, slug: slug)

Pattern: Repo.get_by(Module, field: value)
```

#### 2. Compare Against References

If implementing a library pattern or following documentation:
- Read the reference implementation COMPLETELY
- Don't skim - read EVERY line
- Understand the pattern fully before applying
- Check official docs, not just Stack Overflow

**Example:**
```
Ecto.Repo.get_by/3 documentation says:
- First arg: module name (not instance)
- Second arg: keyword list of fields
- Third arg (optional): query options

My broken code: Repo.get_by(user, :email, "test@example.com")
Correct pattern: Repo.get_by(User, email: "test@example.com")
```

#### 3. Identify Differences

What's different between working and broken code?
- List EVERY difference, however small
- Don't assume "that can't matter"

```bash
# Compare files directly if helpful
diff -u working_controller.ex broken_controller.ex
```

**Example differences to check:**
- Function signatures (arity, parameter types)
- Import/require statements
- Variable naming (is it a module vs instance?)
- Data structures (map vs struct vs keyword list)
- Order of operations

#### 4. Understand Dependencies

- What other components does this pattern need?
- What settings, config, environment variables?
- What assumptions does the pattern make?

**Example:**
```
Repo.get_by/2 requires:
- Ecto.Repo configured in config/config.exs
- Schema module defined (User, Post, etc.)
- Database connection active
- Schema matches database table

Missing any of these = will fail
```

#### Output of Phase 2

```
PATTERN ANALYSIS:

Working example: [file:line showing correct usage]
Reference: [official docs or working implementation]

Key differences between working and broken:
  1. [difference 1]
  2. [difference 2]
  3. [difference 3]

Dependencies required:
  - [component 1]
  - [config 2]
  - [assumption 3]

Correct pattern: [how it should be used]
```

### Phase 3: Hypothesis and Testing

**Goal:** Test your understanding with minimal changes.

Use the scientific method - form hypothesis, test it, verify results.

#### 1. Form Single Hypothesis

State clearly and specifically:
- **"I think X is the root cause because Y"**
- Write it down explicitly
- Be specific, not vague

**Good hypothesis:**
```
I think the error occurs because we're passing a User struct instance 
instead of the User module name to Repo.get_by/2. The function expects 
the module name as first argument according to the docs.
```

**Bad hypothesis:**
```
"Something's wrong with the database call"  ← Too vague
"Maybe it's the query"  ← Not specific
"Could be the user object"  ← Uncertain
```

#### 2. Test Minimally

- Make the SMALLEST possible change to test hypothesis
- Change ONE variable at a time
- Don't fix multiple things at once

**Example minimal test:**
```elixir
# Hypothesis: Need module name, not instance

# Before (broken):
Repo.get_by(user, email: "test@example.com")

# Minimal change to test:
Repo.get_by(User, email: "test@example.com")
#            ^^^^ Changed just this one thing

# Don't also change other things in same test:
# - Don't refactor variable names
# - Don't add error handling
# - Don't "clean up while you're here"
```

#### 3. Verify Before Continuing

Run the test and check results:

- **Did it work?** → Hypothesis CONFIRMED, proceed to Phase 4
- **Didn't work?** → Hypothesis REJECTED, form NEW hypothesis
- **DON'T add more fixes on top of failed attempt**

**If hypothesis rejected:**
1. Note what you learned from this attempt
2. Return to Phase 1 with new information
3. Form a NEW hypothesis based on updated understanding

**Example:**
```
RESULT: Still fails with different error

New error: "no function clause matching in Repo.get_by/2"
New information: get_by/2 expects keyword list, we passed map

REJECTED hypothesis: Module name was the only issue
NEW hypothesis: Need both module name AND keyword list format
```

#### 4. When You Don't Know

If you reach a point where you don't understand:
- Say "I don't understand X"
- Don't pretend to know
- Ask for help or clarification
- Research more (read docs, find examples)

**This is NOT failure** - it's honesty. Better to admit uncertainty than guess wrong.

#### 5. The 3-Fix Rule

**If you've tested 3 hypotheses and all failed:**

**STOP.** Don't try a 4th fix.

This pattern indicates an **architectural problem**, not a simple bug:
- Each fix reveals new issues elsewhere
- Fixes require "massive refactoring"
- Each fix creates new symptoms

**At this point:**
1. Document the 3 failed attempts
2. Explain what you learned from each
3. Question whether the approach/architecture is fundamentally sound
4. Discuss with user before continuing

**See Phase 4, Step 5 for details.**

#### Output of Phase 3

```
HYPOTHESIS:

I think [specific cause] is the problem because [specific evidence from Phase 1/2].

TEST:
Minimal change: [smallest possible fix to test hypothesis]
Expected result: [what should happen if hypothesis is correct]

RESULT:
[actual result after making the change]

Status: CONFIRMED ✅ / REJECTED ❌

[If rejected: what we learned, next hypothesis to test]
```

### Phase 4: Implementation

**Goal:** Fix the root cause with verification at every step.

Now that hypothesis is confirmed, implement the fix properly with tests.

#### 1. Consider Writing a Test Case

**Writing a test is recommended but not required:**

A test that demonstrates the bug:
- Proves the bug exists
- Verifies your fix actually works
- Prevents regression in future
- Documents the expected behavior

**When to write a test:**
- Bug is in critical path
- Bug is likely to recur
- Bug involves complex logic
- Test framework already exists

**When test might not be worth it:**
- Trivial typo or config fix
- One-off environmental issue
- Would require extensive test infrastructure setup

**Example test:**
```elixir
# test/my_app/accounts_test.exs
test "get_by_email returns user when email exists" do
  user = insert(:user, email: "test@example.com")
  
  # This should work but currently fails
  result = Accounts.get_by_email("test@example.com")
  
  assert result == user
end
```

If writing a test, run it first and verify it FAILS with the expected error.

#### 2. Implement Single Fix

Address the root cause identified in Phase 1:
- ONE change at a time
- Fix the SOURCE, not the symptom
- No "while I'm here" improvements
- No bundled refactoring
- No additional features

**Example:**
```elixir
# lib/my_app/accounts.ex

# Before (broken):
def get_by_email(email) do
  user = %User{}
  Repo.get_by(user, email: email)  # Wrong: passing instance
end

# After (fixed):
def get_by_email(email) do
  Repo.get_by(User, email: email)  # Fixed: passing module name
end
```

#### 3. Verify Fix

Run verification steps:

**a) If you wrote a test, run it:**
```bash
mix test test/my_app/accounts_test.exs:15
```
✅ Test should now PASS

**b) Run full test suite if available:**
```bash
mix test
```
✅ All tests should pass (no regressions)

**c) Manually verify:**
- Start application
- Reproduce original steps
- Confirm issue resolved

**d) Check for side effects:**
- Did the fix break anything else?
- Are there related areas that need updates?

#### 4. If Fix Doesn't Work

**Count your attempts:**

- **Attempt 1 failed?** Return to Phase 1, re-analyze with new information
- **Attempt 2 failed?** Return to Phase 1, question your assumptions
- **Attempt 3 failed?** STOP. Read step 5 below.

**Don't try a 4th fix without questioning the architecture.**

#### 5. After 3 Failed Fixes: Question the Architecture

**If 3 hypotheses have been tested and all failed, this indicates an architectural problem:**

**Signs of architectural issues:**
- Each fix reveals new shared state/coupling in different places
- Fixes require "massive refactoring" to implement properly
- Each fix creates new symptoms elsewhere
- The pattern fights against the framework/language
- You're working around the design instead of with it

**At this point, STOP fixing and START questioning:**

Questions to ask:
- Is this pattern fundamentally sound?
- Are we "sticking with it through sheer inertia"?
- Should we refactor the architecture instead of patching symptoms?
- Is there a simpler approach we're not seeing?
- Are we fighting the framework/conventions?

**Discuss with user:**
```
⚠️  ARCHITECTURAL CONCERN

I've attempted 3 different fixes:
1. [Fix 1] - Failed because [reason]
2. [Fix 2] - Failed because [reason]  
3. [Fix 3] - Failed because [reason]

Pattern I'm seeing: [each fix reveals X, or requires Y]

This suggests the approach/architecture might be fundamentally unsound.

Recommendation: [discuss refactoring approach, or alternative architecture]

Should we continue patching, or step back and refactor?
```

**This is NOT a failed hypothesis - this is a signal to refactor.**

#### Output of Phase 4

```
IMPLEMENTATION:

Test created: [test file:line] (if applicable)
Test status before fix: ❌ FAIL (if test written)

Fix applied:
  File: [file changed]
  Change: [description of what was fixed]
  Root cause addressed: [how this fixes the underlying problem]

Verification:
  ✅ New test passes (if written)
  ✅ Full test suite passes (X/X tests, if available)
  ✅ Manual verification successful
  ✅ No regressions detected

Files changed:
  - [file 1]
  - [file 2] (if test file)
```

**If 3+ fixes failed:**
```
⚠️  ARCHITECTURAL CONCERN

Attempts: 3 failed fixes
Pattern: [what pattern you're seeing]
Recommendation: [refactoring approach or discussion needed]

Stopping further fix attempts until architecture is discussed.
```

## Red Flags - STOP and Follow Process

If you catch yourself thinking ANY of these, STOP and return to Phase 1:

**Skipping investigation:**
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"

**Batching changes:**
- "Add multiple changes, run tests"
- "Fix this and refactor while I'm here"
- Multiple fixes in one attempt

**Skipping verification:**
- "Skip the test, I'll manually verify"
- "Tests probably still pass"
- "I'll add tests later"

**Ignoring evidence:**
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow

**Warning signs of architectural issues:**
- "One more fix attempt" (when already tried 2+)
- Each fix reveals new problem in different place
- "This needs massive refactoring to work"

**ALL of these mean: STOP. Follow the process properly.**

## Common Rationalizations (and Why They're Wrong)

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Write the test when it makes sense, not as an afterthought. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Often causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem, not simple bug. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors carefully, reproduce consistently, check recent changes, gather evidence, trace data flow | Can clearly state WHAT broke and WHY |
| **2. Pattern** | Find working examples, compare against references, identify differences, understand dependencies | Understand the CORRECT pattern |
| **3. Hypothesis** | Form specific hypothesis, test minimally (one change), verify results | Hypothesis CONFIRMED (or new hypothesis formed) |
| **4. Implementation** | Consider test, implement single fix, verify completely | Bug resolved, tests pass (if applicable), no regressions |

**Remember:** If 3 hypotheses fail → Question the architecture, not just the implementation.

## Integration with Other Skills

This debugging skill works WITH other skills:

**Complements:**
- **brainstorming** - Use when architectural issues are discovered (after 3 failed fixes)
- **code-standards** - Follow quality standards when implementing fix

## Summary

**Complete debugging flow:**

1. **Phase 1: Root Cause** → Investigate systematically, don't guess
2. **Phase 2: Pattern** → Understand correct implementation
3. **Phase 3: Hypothesis** → Test minimal changes, verify results
4. **Phase 4: Implementation** → Consider test, fix once, verify completely

**Key principles:**
- No fixes without understanding WHY
- One change at a time
- Test when it makes sense (critical bugs, likely to recur)
- 3 failed attempts = architectural issue

**CAPYBARAS DEPEND ON SYSTEMATIC DEBUGGING.** Random fixes make capybaras sad. 🦫
