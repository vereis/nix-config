---
name: planning
description: MANDATORY when given ANY task - provides comprehensive planning workflows including requirement analysis, backend-first ordering, atomic workflow patterns, and task breakdown frameworks. A task is any ad-hoc request, JIRA ticket, GitHub issue, refactoring request, etc.
---

<mandatory>
**MANDATORY**: Plan BEFORE coding - understand requirements, break down tasks, order backend-first.
**CRITICAL**: ALWAYS use this skill for ANY task to work on by a user.
**NO EXCEPTIONS**: Skipping planning = chaos = wasted time and money.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context and spawning additional subagents will not work. Do not attempt to spawn subagents or use TodoWrite from this skill. Instead, follow the planning process directly and return your analysis/recommendations to the primary agent.
</subagent-context>

<core-principles>
1. **Backend-first ordering** - Build from data layer up to UI (DB → Models → Logic → API → Frontend)
2. **Atomic workflow** - Each semantic change followed by test → lint → commit
3. **TodoWrite for planning** - ALL steps captured before starting work
4. **Proactive planning** - Don't wait to be asked, ALWAYS plan first
</core-principles>

<when-to-use>
**ALWAYS use for:**
- User mentions ticket number (JIRA, GitHub, Linear, etc.)
- User says "pick up", "work on", "implement", "fix", "add"
- User describes feature or task to build
- Planning any non-trivial work (more than 1-line fix)

**Don't wait for explicit "plan this" instruction - BE PROACTIVE**
</when-to-use>

<planning-process>
## Step 1: Gather Context

**For JIRA tickets:**
- Consult `jira` skill for viewing tickets and gathering context
- Look for related tickets, blocking issues, epics
- Check for linked PRs if mentioned

**For GitHub issues:**
- Use `gh` to view issue details
- Check for related issues and PRs
- Extract requirements from issue body

**For ad-hoc tasks:**
Ask clarifying questions:
- What's the user-facing goal?
- What's the acceptance criteria?
- Any constraints or dependencies?
- What's the scope (included/excluded)?

## Step 2: Extract Requirements

**Look for:**
- User stories ("As a X, I want Y so that Z")
- Acceptance criteria (Given/When/Then)
- Constraints (performance, security, compatibility)
- Out of scope items
- Dependencies on other work

**Analyze:**
```
What we're building: [1-2 sentence summary]
Why it matters: [business value]
Constraints: [technical limitations]
Dependencies: [blocking tickets/features]
```

## Step 3: Search Codebase for Patterns

- Find similar implementations
- Locate relevant files
- Check existing tests for patterns
- Identify code conventions to match

## Step 4: Backend-First Task Breakdown

**The 5-Layer Ordering (MANDATORY):**

**1. Database/Schema Layer**

What data needs to be stored? What tables/columns?

```
[ ] Add user_settings_audit table migration
  [ ] user_id, changes (jsonb), timestamp
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Why first:**
- Defines what data we're working with
- Other layers build on this foundation
- Schema changes are risky - catch issues early

**2. Model/Type Layer**

How do we represent and validate this data?

```
[ ] Create UserSettings schema
  [ ] Define schema with fields
  [ ] Add changeset with validations
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Why second:**
- Encapsulates data access patterns
- Enforces validation rules
- Provides type safety

**3. Business Logic Layer**

What operations are possible? What rules apply?

```
[ ] Implement update_user_settings/2
  [ ] Core update logic
  [ ] Audit logging
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Why third:**
- Uses models/types from layer above
- Can be tested without UI
- Defines what operations are possible

**4. API/Interface Layer**

How do external consumers interact?

```
[ ] Add PUT /api/user/settings endpoint
  [ ] Request validation
  [ ] Response formatting
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Why fourth:**
- Exposes business logic to consumers
- Defines external contract
- Can be tested with integration tests

**5. Frontend/UI Layer**

What does user see and interact with?

```
[ ] Create settings form component
  [ ] Form fields and validation
  [ ] API integration
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Why last:**
- Depends on working API
- Can iterate on UX without touching backend
- Easiest to change if requirements shift

## Step 5: Atomic Workflow Pattern

**CRITICAL:** After EVERY implementation task, add:
```
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
```

**This is NON-NEGOTIABLE!** Each semantic change must be tested, linted, and committed.

**Benefits:**
- Pinpoint failures - know exactly which change broke things
- Clean history - each commit is tested and linted
- Easier review - reviewers see logical, working increments
- Confidence - know each step is solid before moving on

**What is a semantic change?**

One logical unit of work:
- Add/modify migration file
- Create/update type/model with validation
- Implement single function/method
- Add single API endpoint
- Create single component
- Wire up route/integration point

**NOT semantic change:**
- "Implement user profiles feature" (too big)
- "Update frontend and backend" (multiple layers)
- "Add tests and implementation" (test is verification, not implementation)

## Step 6: Identify Dependencies and Blockers

**Check for:**
- Blocking tickets that must complete first
- Required API endpoints that don't exist yet
- Missing infrastructure or services
- Database migrations needing approval

**If blocked:**
```
This task is blocked!

Blocking issues:
- PROJ-122 (auth refactor) must complete first
- Need database migration approval from DBA team

Fix blockers before starting!
```

## Step 7: Estimate Complexity

**Simple** (< 1 day):
- Single layer change
- No new dependencies
- Clear requirements

**Medium** (1-3 days):
- Multiple layer changes
- Some unknowns to explore
- Standard complexity

**Complex** (> 3 days):
- Touches many layers
- New patterns needed
- High uncertainty
- **Consider splitting into multiple tickets!**

## Step 8: Create TodoWrite List

**MANDATORY:** Use TodoWrite to capture ALL tasks BEFORE starting implementation!

Mental checklists = skipped steps = failures.

**BAD (batching changes):**
```
[ ] Add user_profiles table
[ ] Create UserProfile model
[ ] Add GET /api/user/profile endpoint
[ ] Create profile page component
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
```

**GOOD (atomic with verification after EACH):**
```
[ ] Add user_profiles table migration
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
[ ] Create UserProfile type with validation
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
[ ] Implement get_user_profile/1 function
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
[ ] Add GET /api/user/profile endpoint
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
[ ] Create ProfileSettings component
[ ] Run quality-check subagent
[ ] Run quality-check subagent (lint)
[ ] Run commit subagent
```

## Step 9: Present Plan to User

Show complete breakdown:
```
Task: PROJ-123 - Add user settings with audit logging

Requirements:
- Users can update email, name, avatar
- All changes must be audited
- Validation on email format

Task Breakdown (Backend-First + Atomic Workflow):

Database Layer:
[ ] Add user_settings_audit table
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent

Model Layer:
[ ] Create UserSettings schema with validations
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent

... (rest of layers)

Estimated complexity: Medium
Blockers: None
Dependencies: Requires auth middleware (already exists)

Ready to start? (yes/no)
```
</planning-process>

<handling-failures>
**If tests fail during atomic workflow:**

1. Fix the issue immediately
2. Re-run quality-check subagent
3. Don't move to next task until passing

**OPTIMIZATION: Failed-only test mode**

When fixing test failures, you MAY request `failed-only` mode if:
- ✅ Implementing fix based on specific test failures
- ✅ Other tests have already passed in previous run
- ✅ Want to verify fix without re-running entire suite

Request by instructing quality-check subagent:
```
"Run quality-check subagent with scope=failed-only to verify the fix"
```

**When NOT to use failed-only:**
- ❌ First test run (no previous failures to track)
- ❌ Changes to shared utilities (need full test suite)
- ❌ When in doubt (always default to full suite)
</handling-failures>

<anti-rationalization>
**THESE EXCUSES NEVER APPLY**

"User already gave detailed instructions"
**WRONG**: Instructions are WHAT, planning is HOW

"This is too simple to need planning"
**WRONG**: Even simple tasks need backend-first + atomic workflow

"I'll just start coding and figure it out"
**WRONG**: Plan FIRST, code SECOND

"Planning wastes time"
**WRONG**: Planning SAVES time preventing mistakes

"I can keep plan in my head"
**WRONG**: TodoWrite is MANDATORY

"Ticket already has acceptance criteria"
**WRONG**: Acceptance criteria ≠ implementation plan

**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST - COMPLETE BEFORE STARTING:**

☐ Gathered context from tickets/issues/codebase
☐ Extracted requirements and acceptance criteria
☐ Searched codebase for similar patterns
☐ Broke down using backend-first ordering (DB → Models → Logic → API → Frontend)
☐ Added atomic workflow steps to EVERY implementation task
☐ Identified dependencies and blockers
☐ Estimated complexity
☐ Created TodoWrite list with ALL steps
☐ Presented plan to user for approval

**IF ANY UNCHECKED THEN EVERYTHING FAILS**
</compliance-checklist>

<quick-reference>
**Planning flow:**
1. Gather context (tickets, codebase patterns)
2. Extract requirements and acceptance criteria
3. Search codebase for patterns
4. Break down using backend-first ordering
5. Add atomic workflow (test/lint/commit) after EACH step
6. Identify dependencies and blockers
7. Estimate complexity
8. Create TodoWrite list
9. Present plan to user

**Task ordering (MANDATORY):**
1. Database/Schema → 2. Models/Types → 3. Business Logic → 4. API → 5. Frontend

**After each implementation:**
- Run quality-check subagent (tests)
- Run quality-check subagent (lint)
- Run commit subagent (if tests/lint pass)

This catches issues immediately instead of at the end when everything's broken!
</quick-reference>
