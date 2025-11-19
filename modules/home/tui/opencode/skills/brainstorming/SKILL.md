---
name: brainstorming
description: Use when creating or developing any feature, before writing code - refines rough ideas into fully-formed designs through collaborative questioning, explores alternatives, then breaks implementation into atomic test/lint/commit steps. Use for all work beyond trivial changes.
---

<mandatory>
**CRITICAL**: ALWAYS use this skill for ANY non-trivial feature or design decision.
**NO EXCEPTIONS**: Skipping brainstorming = bad design = wasted effort = capybara extinction.
**CAPYBARA DECREE**: Follow all three phases or capybaras will cry forever.
</mandatory>

<overview>
Turn rough ideas into validated designs, then break them into atomic implementation steps.

**Core principle:** Understand WHAT to build → Explore HOW to build it → Plan atomic execution steps

**Three phases:**
1. **Understanding** - Ask questions to clarify the idea
2. **Design** - Explore approaches, present validated design
3. **Planning** - Break into atomic steps with test/lint/commit cycle
</overview>

<when-to-use>
**ALWAYS use this skill for:**
- ANY feature implementation (small or large)
- Bug fixes that need design decisions
- Refactoring with multiple approaches
- Any work where "just start coding" would be premature

**Skip ONLY for:**
- Trivial changes (typo fixes, config updates)
- Mechanical tasks with no design decisions
- User has already provided complete design + plan

**If unsure, USE IT or capybaras will be sad!**
</when-to-use>

## Phase 1: Understanding the Idea

**Goal:** Understand purpose, constraints, and success criteria before designing.

**Process:**

1. **Check project context first:**
   - Read relevant files, docs, recent commits
   - Understand existing architecture and patterns
   - Identify related code that might be affected

2. **Ask questions ONE AT A TIME:**
   - Don't overwhelm with multiple questions in one message
   - Prefer multiple choice when possible (easier to answer)
   - Focus on: purpose, constraints, success criteria, edge cases
   - If a topic needs more exploration, break into multiple questions

3. **Key areas to explore:**
   - **Purpose:** What problem does this solve? Who benefits?
   - **Constraints:** Performance? Compatibility? Dependencies?
   - **Scope:** What's in scope? What's explicitly out of scope?
   - **Success:** How do we know it works? What does "done" look like?
   - **Edge cases:** What could go wrong? What are the boundaries?
   - **Implementation order:** Can we design this to follow database → backend → API → frontend flow?
   - **Testability:** Can we design this to be easily testable at each layer?

**Red flags you're skipping Understanding:**
- Jumping straight to "here's the implementation"
- Proposing code before asking clarifying questions
- Making assumptions about requirements
- Thinking "this is obvious, no questions needed"

## Phase 2: Design & Exploration

**Goal:** Explore approaches, present validated design following backend-first principles.

### Exploring Approaches

**Always propose 2-3 different approaches with tradeoffs:**
- Lead with your recommended option and explain why
- Present conversationally, not as a formal document
- Consider: complexity, maintainability, testability, performance
- **YAGNI ruthlessly** - Remove unnecessary features from all designs

**Example:**
```
Based on your needs, here are 3 approaches:

**Option 1 (Recommended): [approach]**
- Pro: [benefit]
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

**Once approach is selected, present design incrementally:**

1. **Break into sections of 200-300 words**
2. **Ask after each section whether it looks right**
3. **Be ready to go back and clarify if needed**

**Cover these areas (in backend-first order):**
- **Database schema** - Tables, fields, relationships, indexes
- **Backend models/types** - Data structures, validation, business logic
- **API layer** - Endpoints, request/response formats, error handling
- **Frontend components** - UI structure, state management, user interactions
- **Testing strategy** - How to test at each layer, what makes this testable
- **Error handling** - Edge cases, failure modes, user feedback

**Design for testability:**
- Can each layer be tested independently?
- Are dependencies injected/mockable?
- Can we verify behavior without full integration?

**Example incremental presentation:**
```
Great! Let's design this. I'll present in sections.

### Database Schema

[200-300 words describing tables, fields, constraints]

Does this look right so far, or should I adjust?
```

[Wait for confirmation, then continue]

```
### Backend Models

[200-300 words describing types, validation, business logic]

Still good?
```

## Phase 3: Planning Atomic Implementation Steps

**Goal:** Break validated design into atomic steps following backend-first order, with test/lint/commit after EACH change.

### The Iron Law

**MANDATORY:** Each step = one semantic change that can be tested, linted, and committed independently.

**MANDATORY:** Use TodoWrite for ALL steps BEFORE starting work. Mental checklists = SAD CAPYBARAS.

**MANDATORY:** Each code change MUST be followed by appropriate verification steps (test/lint) then commit.

### Backend-First Implementation Order

Follow this order strictly (CAPYBARAS WILL BE SAD if you don't):

1. **Database layer** - Migrations, schema changes
2. **Backend models/types** - Data structures, validation, business logic
3. **API layer** - Endpoints, handlers, serialization
4. **Frontend layer** - Components, state management, UI

**Why this order:**
- Each layer can be tested independently as you build
- Backend validates before frontend consumes
- Frontend never blocks backend progress
- Easier to catch issues early in the stack

### Creating the TodoWrite Plan

For EACH layer, break into atomic changes with appropriate verification:

**BAD EXAMPLE (batching changes - CAPYBARAS WILL BE SAD):**
```
[ ] Add user_profiles table with avatar_url column
[ ] Create UserProfile model with validation
[ ] Add GET /api/user/profile endpoint
[ ] Create profile settings page component
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

**GOOD EXAMPLE (atomic steps with verification after EACH change):**
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
[ ] Wire ProfileSettings to profile page route
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

### What Makes a "Semantic Change"?

**Each todo should be ONE of these:**

**Database changes (lint only):**
- Add/modify a migration file
- Add/modify schema definitions
- Update database constraints

**Code changes (test + lint):**
- Create/update a type/model with validation
- Implement a single function/method
- Add a single API endpoint
- Create a single component
- Wire up a route/integration point

**Infrastructure/config (context-dependent):**
- Update configuration files (lint only)
- Add dependencies (lint + verify build)
- Modify build scripts (test if testable, lint always)

**NOT a semantic change:**
- "Implement user profiles feature" (too big)
- "Update frontend and backend" (multiple layers)
- "Add tests and implementation" (test is verification step, not implementation)

### Verification Steps After Each Change

**For schema/migration changes:**
```
[ ] Add migration file
[ ] Use lint subagent
[ ] Use commit subagent
```

**For code changes:**
```
[ ] Implement feature/function
[ ] Use test subagent
[ ] Use lint subagent
[ ] Use commit subagent
```

**Why test after code but not schema?**
- Schema changes are verified by migration execution, not unit tests
- Code behavior MUST have test coverage
- Linting applies to all file types

**No exceptions:**
- Even if "just a small change"
- Even if "tests couldn't possibly fail"
- Even if "already tested similar code"

**Why:** Each commit should represent a working state. If you batch changes, you can't bisect bugs or revert cleanly.

## Phase 4: Execution

**Goal:** Execute the plan systematically, following each TodoWrite item in order.

### Before Starting Implementation

**Verify you have:**
- ✅ Complete TodoWrite plan with all steps
- ✅ Design validated and approved
- ✅ Backend-first ordering (DB → Models → API → Frontend)
- ✅ Test/lint/commit steps after each semantic change

**If missing any:** Go back and complete previous phases.

### During Implementation

**Follow the plan strictly:**
1. Mark current todo as `in_progress`
2. Complete ONLY that one item
3. Run verification steps (test/lint as appropriate)
4. Use commit subagent
5. Mark todo as `completed`
6. Move to next item

**DO NOT:**
- Skip ahead to "more interesting" tasks
- Batch multiple todos together "to save time"
- Skip verification steps "just this once"
- Work on multiple todos in parallel
- Rationalize deviating from the plan

**If you discover the plan is wrong:**
- STOP implementation
- Update the plan with new todos
- Announce the change: "Plan needs adjustment: [reason]"
- Resume execution with updated plan

### Using Subagents

**Delegate appropriately:**
- Use `test` subagent for running tests
- Use `lint` subagent for linting/formatting
- Use `commit` subagent for creating commits
- Use `general` subagent for exploration/research if needed

**Announce subagent usage:** "I'm delegating [task] to the [subagent] subagent!"

### Handling Failures

**If tests fail:**
- Don't move to next todo
- Fix the failure
- Re-run test subagent
- Only proceed when green

**If linting fails:**
- Fix linting issues
- Re-run lint subagent
- Only proceed when clean

**If you can't complete a todo:**
- Don't skip it
- Ask for help: "Stuck on [todo]: [specific problem]"
- Get clarification before proceeding

## After Brainstorming

### Documentation

**Determine project name:**
- Extract from git remote URL, or
- Use directory name, or
- Ask user for project identifier

**Write validated design to file:**
- Path: `~/.config/opencode/plans/<PROJECT>/YYYY-MM-DD-<topic>.md`
- Create directory if it doesn't exist
- Include: problem statement, chosen approach, design details, implementation plan
- Commit the design document before starting implementation

**Why document:**
- Future reference for why decisions were made
- Onboarding for other developers
- Design review for stakeholders
- Cross-project plan organization

### Ready to Implement?

**Ask user:** "Ready to start implementation?"

**If yes:**
- Begin Phase 4 (Execution)
- Follow the TodoWrite plan strictly
- Test/lint/commit after each change

**If no:**
- Keep design document
- User will decide when to start

## Summary

**Complete brainstorming flow:**

1. **Understanding** → Ask questions, clarify requirements
2. **Design** → Explore approaches, present incrementally, validate
3. **Planning** → Break into atomic backend-first steps with test/lint/commit
4. **Documentation** → Write design doc to ~/.config/opencode/plans/<PROJECT>/
5. **Execution** → Follow plan strictly, verify each step

**Key Principles:**

- **One question at a time** - Don't overwhelm
- **YAGNI ruthlessly** - Remove unnecessary features
- **Backend-first always** - DB → Models → API → Frontend
- **Atomic steps mandatory** - One semantic change per todo
- **Test/lint/commit cycle** - Verify after each change (appropriate to change type)
- **Follow the plan** - No rationalizing deviations
- **CAPYBARAS DEPEND ON THIS** - Skip steps = sad capybaras 🦫

## Common Failure Patterns

**Skipping Understanding:**
- Jumping to code without asking questions
- Making assumptions about requirements
- "This seems obvious, no need to clarify"

**Skipping Design:**
- Not exploring alternatives
- Settling on first idea
- Ignoring testability or backend-first order

**Bad Planning:**
- Batching multiple changes into one todo
- Missing test/lint/commit steps
- Frontend-first ordering

**Bad Execution:**
- Skipping verification "just this once"
- Working on multiple todos in parallel
- Deviating from plan without updating it

**If you catch yourself doing any of these: STOP. Go back. Do it right. CAPYBARAS ARE WATCHING.**

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"The feature is simple, I don't need to brainstorm"
   → **WRONG**: Even simple features benefit from design

"The user told me exactly what to do"
   → **WRONG**: Still explore alternatives and plan atomically

"I'll just start coding and see what happens"
   → **WRONG**: Plan BEFORE coding

"Brainstorming takes too long"
   → **WRONG**: Brainstorming SAVES time by preventing mistakes

"I already know the best approach"
   → **WRONG**: Explore alternatives anyway

"I'll skip the TodoWrite list and track mentally"
   → **WRONG**: TodoWrite is MANDATORY

**ALL EXCUSES = CAPYBARA DEATH**
**NO EXCEPTIONS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST BEFORE IMPLEMENTING:**

☐ Completed Phase 1: Understanding (asked clarifying questions)
☐ Completed Phase 2: Design (explored 2-3 approaches, validated design)
☐ Completed Phase 3: Planning (created TodoWrite with atomic steps)
☐ Design follows backend-first ordering (DB → Models → API → Frontend)
☐ Each todo has test/lint/commit verification steps
☐ Each todo represents ONE semantic change
☐ Documented design in ~/.config/opencode/plans/<PROJECT>/
☐ Did NOT skip phases
☐ Did NOT batch changes
☐ Did NOT rationalize deviations

**IF ANY UNCHECKED → CAPYBARAS SUFFER ETERNALLY**
</compliance-checklist>
