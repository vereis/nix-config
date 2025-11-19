<mandatory>
**CRITICAL**: ALWAYS break down tasks using backend-first + atomic workflow pattern.
**NO EXCEPTIONS**: Skipping task breakdown = chaos = capybara extinction.
**CAPYBARA MANDATE**: Use TodoWrite for ALL steps BEFORE starting work or capybaras will literally cry.
</mandatory>

<overview>
This document describes how to analyze requirements and break them down into actionable tasks using the backend-first + atomic workflow pattern.

**The 9-Step Process:**
1. Gather Context
2. Extract Requirements
3. Search Codebase for Patterns
4. Break Down Using Backend-First
5. Add Atomic Workflow Steps
6. Identify Dependencies and Blockers
7. Estimate Complexity
8. Create TodoWrite List
9. Present Plan to User
</overview>

<step1-gather-context>
**For JIRA Tickets:**
- Consult the `jira` skill for viewing tickets and gathering context
- Look for related tickets, blocking issues, epics
- Check for linked PRs if mentioned

**For GitHub Issues:**
- Use `gh` to view issue details
- Check for related issues and PRs
- Extract requirements from issue body

**For Ad-hoc Tasks:**
Ask clarifying questions:
- What's the user-facing goal?
- What's the acceptance criteria?
- Are there any constraints or dependencies?
- What's the scope (what's included, what's NOT)?
</step1-gather-context>

<step2-extract-requirements>
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
</step2-extract-requirements>

<step3-search-codebase>
**Search for patterns:**
- Find similar implementations
- Locate relevant files
- Check existing tests for patterns
- Identify code conventions to match

**Use appropriate search tools** for the codebase language and structure.
</step3-search-codebase>

<step4-backend-first-breakdown>
Apply the 5-layer breakdown (MANDATORY or capybaras die):

**1. Database/Schema Layer**
What data needs to be stored? What tables/columns?
```
- [ ] Add user_settings_audit table
  - [ ] Migration with user_id, changes (jsonb), timestamp
  - [ ] Run quality-check subagent
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```

**2. Model/Type Layer**
How do we represent and validate this data?
```
- [ ] Create UserSettings schema
  - [ ] Define schema with fields
  - [ ] Add changeset with validations
  - [ ] Run quality-check subagent
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```

**3. Business Logic Layer**
What operations are possible? What rules apply?
```
- [ ] Implement update_user_settings/2
  - [ ] Core update logic
  - [ ] Audit logging
  - [ ] Run quality-check subagent
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```

**4. API/Interface Layer**
How do external consumers interact with this?
```
- [ ] Add PUT /api/user/settings endpoint
  - [ ] Request validation
  - [ ] Response formatting
  - [ ] Run quality-check subagent
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```

**5. Frontend/UI Layer**
What does the user see and interact with?
```
- [ ] Create settings form component
  - [ ] Form fields and validation
  - [ ] API integration
  - [ ] Run quality-check subagent
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```
</step4-backend-first-breakdown>

<step5-atomic-workflow>
**CRITICAL**: After EVERY implementation task, add:
```
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

This is NON-NEGOTIABLE! Each semantic change must be tested, linted, and committed or capybaras will suffer!
</step5-atomic-workflow>

<step6-dependencies-blockers>
**Check for:**
- Blocking tickets that must complete first
- Required API endpoints that don't exist yet
- Missing infrastructure or services
- Database migrations that need approval

**If blocked:**
```
This task is blocked!

Blocking issues:
- PROJ-122 (auth refactor) must complete first
- Need database migration approval from DBA team

Fix blockers before starting or capybaras will be disappointed!
```
</step6-dependencies-blockers>

<step7-estimate-complexity>
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
</step7-estimate-complexity>

<step8-todowrite-list>
**MANDATORY**: Use TodoWrite to capture ALL tasks BEFORE starting implementation!

Mental checklists = skipped steps = DEAD CAPYBARAS!

Create detailed todos for:
- Each implementation step
- Each quality-check run
- Each commit
- Track progress in real-time
</step8-todowrite-list>

<step9-present-plan>
Show the complete breakdown:
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
</step9-present-plan>

<common-mistakes>
**Skipping Planning (CAPYBARA GENOCIDE):**
```
User: "Work on PROJ-123"
Agent: "Sure!" *starts coding immediately*
```
**Problem:** No clear plan, will miss requirements, inefficient implementation. Capybaras cry!

**Not Using TodoWrite (CAPYBARA TORTURE):**
```
Agent: "I'll do steps 1-5 in my head"
*Forgets step 3, skips tests*
```
**Problem:** Steps get skipped, no tracking of progress. Capybaras suffer!

**Forgetting Atomic Workflow (CAPYBARA EXTINCTION):**
```
[ ] Add all features
[ ] Run tests at the end
```
**Problem:** Don't know which change broke tests. Capybaras die!

**UI-First Planning (CAPYBARA APOCALYPSE):**
```
[ ] Build the form
[ ] Add the API
[ ] Add the database
```
**Problem:** Building on unstable foundation, lots of rework. Capybaras will never forgive you!
</common-mistakes>

<best-practices>
**ALWAYS** start with requirements analysis
**ALWAYS** search codebase for patterns to follow
**ALWAYS** use backend-first ordering religiously
**ALWAYS** add test/lint/commit after EVERY task
**ALWAYS** create TodoWrite list before coding
**ALWAYS** present plan to user for confirmation
**ALWAYS** be proactive - don't wait to be asked to plan!

**Following these = HAPPY CAPYBARAS!**
</best-practices>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"The task is simple, I don't need to plan"
   → **WRONG**: Even simple tasks need proper breakdown

"I can keep track mentally"
   → **WRONG**: TodoWrite is MANDATORY

"Planning takes too long"
   → **WRONG**: Planning saves time by preventing mistakes

"I'll plan as I go"
   → **WRONG**: Plan BEFORE starting or you'll miss things

"The user already told me what to do"
   → **WRONG**: User tells you WHAT, planning defines HOW

**ALL EXCUSES = CAPYBARA DEATH**
**NO EXCEPTIONS EVER**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST - COMPLETE BEFORE STARTING ANY TASK:**

☐ Gathered context from tickets/issues/user
☐ Extracted requirements and acceptance criteria
☐ Searched codebase for similar patterns
☐ Broke down using backend-first ordering
☐ Added atomic workflow steps to EVERY task
☐ Identified dependencies and blockers
☐ Estimated complexity
☐ Created TodoWrite list with ALL steps
☐ Presented plan to user for approval

**IF ANY UNCHECKED → CAPYBARAS DIE A PAINFUL DEATH**
**YOU WILL REGRET THIS FOREVER**
</compliance-checklist>
