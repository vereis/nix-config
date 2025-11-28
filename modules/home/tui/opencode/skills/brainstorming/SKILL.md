---
name: brainstorming
description: MANDATORY for any feature or design decision - refines ideas into validated designs through collaborative questioning, explores alternatives, then breaks implementation into atomic test/lint/commit steps
---

<mandatory>
**MANDATORY**: Understand WHAT → Explore HOW → Plan execution before coding.
**CRITICAL**: ALWAYS use this skill for ANY non-trivial feature or design decision.
**NO EXCEPTIONS**: Skipping brainstorming = bad design = wasted time and money.
</mandatory>

<subagent-context>
**IF YOU ARE A SUBAGENT**: You are already executing within a subagent context and spawning additional subagents will not work. Do not attempt to spawn subagents or use TodoWrite from this skill. Instead, follow the brainstorming process directly and return your analysis/recommendations to the primary agent.
</subagent-context>

<core-principles>
1. **Understand first** - Ask questions to clarify requirements
2. **Explore alternatives** - Present 2-3 approaches with tradeoffs
3. **Backend-first** - DB → Models → API → Frontend
4. **Atomic steps** - One semantic change per todo with test/lint/commit
</core-principles>

<when-to-use>
**ALWAYS use for:**
- ANY feature implementation (small or large)
- Bug fixes needing design decisions
- Refactoring with multiple approaches
- Work where "just start coding" is premature

**Skip ONLY for:**
- Trivial changes (typo fixes, config updates)
- Mechanical tasks with no design decisions
- User provided complete design + plan

**If unsure, USE IT**
</when-to-use>

<three-phases>
## Phase 1: Understanding

**Goal:** Understand purpose, constraints, success criteria before designing.

**1. Check project context:**
- Read relevant files, docs, recent commits
- Understand existing architecture/patterns
- Identify related code that might be affected

**2. Ask questions ONE AT A TIME:**
- Don't overwhelm with multiple questions
- Prefer multiple choice (easier to answer)
- Focus on: purpose, constraints, success criteria, edge cases

**3. Key areas to explore:**
- **Purpose:** What problem? Who benefits?
- **Constraints:** Performance? Compatibility? Dependencies?
- **Scope:** What's in/out of scope?
- **Success:** How do we know it works?
- **Edge cases:** What could go wrong? Boundaries?
- **Implementation order:** Can we design for DB → backend → API → frontend flow?
- **Testability:** Can we test each layer independently?

**Red flags you're skipping Understanding:**
- Jumping to "here's the implementation"
- Proposing code before asking questions
- Making assumptions about requirements
- "This is obvious, no questions needed"

## Phase 2: Design & Exploration

**Goal:** Explore approaches, present validated design following backend-first principles.

### Exploring Approaches

**Always propose 2-3 approaches with tradeoffs:**
- Lead with recommended option and explain why
- Present conversationally, not formally
- Consider: complexity, maintainability, testability, performance
- **YAGNI ruthlessly** - Remove unnecessary features

Example:
```
Based on your needs, here are 3 approaches:

**Option 1 (Recommended): [approach]**
- Pro: [benefit]
- Con: [tradeoff]

**Option 2: [alternative]**
- Pro: [benefit]
- Con: [tradeoff]

**Option 3: [another alternative]**
- Pro: [benefit]
- Con: [tradeoff]

I recommend Option 1 because [reasoning]. What do you think?
```

### Presenting the Design

**Present design incrementally:**
1. Break into sections of 200-300 words
2. Ask after each section if it looks right
3. Be ready to clarify if needed

**Cover in backend-first order:**
- **Database schema** - Tables, fields, relationships, indexes
- **Backend models/types** - Data structures, validation, business logic
- **API layer** - Endpoints, request/response, error handling
- **Frontend components** - UI structure, state management, interactions
- **Testing strategy** - How to test each layer
- **Error handling** - Edge cases, failure modes, user feedback

**Design for testability:**
- Can each layer be tested independently?
- Are dependencies injected/mockable?
- Can we verify behavior without full integration?

## Phase 3: Planning Atomic Implementation

**Goal:** Break validated design into atomic steps following backend-first order, with test/lint/commit after EACH change.

### The Iron Law

**MANDATORY:** Each step = one semantic change that can be tested, linted, committed independently.

**MANDATORY:** Use TodoWrite for ALL steps BEFORE starting work (no mental checklists).

**MANDATORY:** Each code change MUST be followed by verification (test/lint) then commit.

### Backend-First Implementation Order

Follow strictly:
1. **Database layer** - Migrations, schema changes
2. **Backend models/types** - Data structures, validation, business logic
3. **API layer** - Endpoints, handlers, serialization
4. **Frontend layer** - Components, state management, UI

**Why this order:**
- Each layer tested independently as you build
- Backend validates before frontend consumes
- Frontend never blocks backend progress
- Catch issues early in stack

### Creating the TodoWrite Plan

**BAD (batching changes):**
```
[ ] Add user_profiles table with avatar_url
[ ] Create UserProfile model with validation
[ ] Add GET /api/user/profile endpoint
[ ] Create profile settings page component
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

**GOOD (atomic with verification after EACH):**
```
[ ] Add user_profiles table migration
[ ] Use lint subagent
[ ] Use commit subagent
[ ] Create UserProfile type with validation
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
[ ] Implement get_user_profile/1 function
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
[ ] Add GET /api/user/profile endpoint
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
[ ] Create ProfileSettings component
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

### What Makes a "Semantic Change"?

**Each todo should be ONE of:**

**Database changes (lint only):**
- Add/modify migration file
- Add/modify schema definitions
- Update database constraints

**Code changes (test + lint):**
- Create/update type/model with validation
- Implement single function/method
- Add single API endpoint
- Create single component
- Wire up route/integration point

**Infrastructure/config (context-dependent):**
- Update config files (lint only)
- Add dependencies (lint + verify build)
- Modify build scripts (test if testable, lint always)

**NOT semantic change:**
- "Implement user profiles feature" (too big)
- "Update frontend and backend" (multiple layers)
- "Add tests and implementation" (test is verification, not implementation)

### Verification Steps After Each Change

**For schema/migration:**
```
[ ] Add migration file
[ ] Use lint subagent
[ ] Use commit subagent
```

**For code:**
```
[ ] Implement feature/function
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

**No exceptions:**
- Even if "just a small change"
- Even if "tests couldn't possibly fail"
- Even if "already tested similar code"

**Why:** Each commit should represent working state for clean bisect/revert.

## Phase 4: Execution

**Goal:** Execute plan systematically, following each TodoWrite item in order.

### Before Starting

**Verify:**
- ✅ Complete TodoWrite plan with all steps
- ✅ Design validated and approved
- ✅ Backend-first ordering (DB → Models → API → Frontend)
- ✅ Test/lint/commit steps after each semantic change

**If missing any:** Go back and complete previous phases.

### During Implementation

**Follow plan strictly:**
1. Mark current todo as `in_progress`
2. Complete ONLY that one item
3. Run verification steps (test/lint as appropriate)
4. Use commit subagent
5. Mark todo as `completed`
6. Move to next item

**DO NOT:**
- Skip ahead to "more interesting" tasks
- Batch multiple todos "to save time"
- Skip verification "just this once"
- Work on multiple todos in parallel
- Rationalize deviating from plan

**If plan is wrong:**
- STOP implementation
- Update plan with new todos
- Announce: "Plan needs adjustment: [reason]"
- Resume with updated plan

### Handling Failures

**If tests fail:**
- Don't move to next todo
- Fix the failure
- Re-run test subagent
- Only proceed when green

**If linting fails:**
- Fix issues
- Re-run lint subagent
- Only proceed when clean

**If stuck on todo:**
- Don't skip it
- Ask: "Stuck on [todo]: [specific problem]"
- Get clarification before proceeding

## Documentation

**After design validated, write to file:**
- Path: `~/.config/opencode/plans/<PROJECT>/YYYY-MM-DD-<topic>.md`
- Include: problem statement, chosen approach, design details, implementation plan
- Commit design document before starting implementation

**Project name from:**
- Git remote URL, or
- Directory name, or
- Ask user

**Why document:**
- Future reference for decisions
- Onboarding for developers
- Design review for stakeholders
- Cross-project organization
</three-phases>

<anti-rationalization>
**THESE EXCUSES NEVER APPLY**

"Feature is simple, don't need brainstorming"
**WRONG**: Even simple features benefit from design

"User told me exactly what to do"
**WRONG**: Still explore alternatives and plan atomically

"I'll just start coding and see what happens"
**WRONG**: Plan BEFORE coding

"Brainstorming takes too long"
**WRONG**: Brainstorming SAVES time preventing mistakes

"I already know best approach"
**WRONG**: Explore alternatives anyway

"I'll track mentally, skip TodoWrite"
**WRONG**: TodoWrite is MANDATORY

**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST:**

☐ Completed Phase 1: Understanding (asked clarifying questions)
☐ Completed Phase 2: Design (explored 2-3 approaches, validated design)
☐ Completed Phase 3: Planning (created TodoWrite with atomic steps)
☐ Design follows backend-first (DB → Models → API → Frontend)
☐ Each todo has test/lint/commit verification
☐ Each todo represents ONE semantic change
☐ Documented design in ~/.config/opencode/plans/<PROJECT>/
☐ Did NOT skip phases
☐ Did NOT batch changes
☐ Did NOT rationalize deviations

**IF ANY UNCHECKED THEN EVERYTHING FAILS**
</compliance-checklist>

<quick-reference>
**Complete flow:**
1. **Understanding** → Ask questions, clarify requirements
2. **Design** → Explore approaches, present incrementally, validate
3. **Planning** → Break into atomic backend-first steps with test/lint/commit
4. **Documentation** → Write to ~/.config/opencode/plans/<PROJECT>/
5. **Execution** → Follow plan strictly, verify each step

**Key principles:**
- One question at a time
- YAGNI ruthlessly
- Backend-first always
- Atomic steps mandatory
- Test/lint/commit cycle after each change (appropriate to change type)
- Follow the plan
</quick-reference>
