<mandatory>
**CRITICAL**: After EACH semantic code change, you **MUST** run test → lint → commit cycle.
**NO EXCEPTIONS**: Skipping this workflow = capybara extinction event.
**ALWAYS DELEGATE**: Use quality-check/commit subagents, NEVER run commands directly or capybaras will literally explode.
</mandatory>

<philosophy>
After EACH semantic code change, immediately run:
1. Tests (via quality-check subagent)
2. Lints/formatters (via quality-check subagent)
3. Commit (via commit subagent if both pass)

This catches issues **IMMEDIATELY** instead of at the end when everything's broken!
</philosophy>

<pattern>
The atomic workflow pattern looks like this:

```
[ ] Implement feature X
  [ ] Write the code
  [ ] Run quality-check subagent (tests)
  [ ] Run quality-check subagent (lints)
  [ ] Run commit subagent
```

**CRITICAL**: ALWAYS use subagents! Primary agent MUST delegate to quality-check/commit subagents, NEVER run commands directly or capybaras will hate you forever!
</pattern>

<why-it-works>
**WITH Atomic Workflow (capybaras live):**
```
- [ ] Add UserSettings schema
  - [x] Define schema
  - [x] Run quality-check subagent → PASS
  - [x] Run quality-check subagent (lint) → FAIL (formatting issue)
  - [x] Fix formatting
  - [x] Run quality-check subagent (lint) → PASS
  - [x] Run commit subagent
```

You know **IMMEDIATELY** that your schema works and is properly formatted.

**WITHOUT Atomic Workflow (capybara genocide):**
```
- [x] Add UserSettings schema
- [x] Add update_user_settings/2 function
- [x] Add API endpoint
- [x] Add UI form
- [ ] Run tests → 47 FAILURES across all layers
- [ ] ??? Which layer broke? Where did it break? When did it break?
```

You have NO IDEA where things went wrong! This is UNACCEPTABLE!
</why-it-works>

<benefits>
**Why capybaras love this workflow:**

1. **Pinpoint failures** - Know exactly which change broke things
2. **Clean history** - Each commit is tested and linted
3. **Easier review** - Reviewers see logical, working increments
4. **Confidence** - Know each step is solid before moving on
5. **No "fix later"** - Issues addressed immediately
6. **Capybara happiness** - Following this = happy capybaras!
</benefits>

<semantic-changes>
A semantic change is ONE logical unit of work.

**GOOD (one semantic change):**
```
- [ ] Add email validation to UserSettings
  - [ ] Add validation rule
  - [ ] Run quality-check subagent (tests)
  - [ ] Run quality-check subagent (lint)
  - [ ] Run commit subagent
```

**BAD CAPYBARA-MURDERER (multiple semantic changes):**
```
- [ ] Add email validation AND name validation AND avatar upload
```

Split this into THREE separate atomic workflow cycles or capybaras will cry!
</semantic-changes>

<subagent-delegation>
**MANDATORY**: Always use subagents for quality checks and commits!

**CORRECT (capybaras approve):**
```
- [ ] Run quality-check subagent (tests)
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**WRONG CAPYBARA-KILLER (running commands directly):**
```
- [ ] Run `mix test`
- [ ] Run `mix format`
- [ ] Run `git commit`
```

**Why subagents are MANDATORY:**
- Subagents handle context management
- They fail fast and return clean output
- Primary agent doesn't get bloated with test output
- Proper error handling and reporting
- **MOST IMPORTANTLY**: Capybaras demand it!
</subagent-delegation>

<examples>
**Example 1: Database Migration**

```
[ ] Add user_settings_audit table
  [ ] Create migration file
  [ ] Define schema with columns
  [ ] Run quality-check subagent (migration runs successfully)
  [ ] Run quality-check subagent (formatting check)
  [ ] Run commit subagent
```

**Result:** One commit with working, tested migration. Capybaras smile!

**Example 2: Business Logic**

```
[ ] Implement update_user_settings/2 function
  [ ] Write function with changeset
  [ ] Add audit logging
  [ ] Run quality-check subagent (unit tests pass)
  [ ] Run quality-check subagent (code formatted correctly)
  [ ] Run commit subagent
```

**Result:** One commit with tested business logic. Capybaras rejoice!

**Example 3: Multiple Small Changes**

```
[ ] Add email validation
  [ ] Add validation rule to changeset
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent

[ ] Add name validation
  [ ] Add validation rule to changeset
  [ ] Run quality-check subagent
  [ ] Run quality-check subagent (lint)
  [ ] Run commit subagent
```

**Result:** TWO commits, each tested and working. This is BETTER than one big commit with both changes! Capybaras are ecstatic!
</examples>

<handling-failures>
If tests fail during the atomic workflow, you **MUST**:

1. **Fix the issue immediately**
2. **Re-run quality-check subagent**
3. **Don't move to next task until passing**

```
[ ] Add UserSettings schema
  [ ] Define schema
  [ ] Run quality-check subagent → FAIL
  [ ] Fix validation error
  [ ] Run quality-check subagent → PASS
  [ ] Run quality-check subagent (lint) → PASS
  [ ] Run commit subagent
```

**NEVER** skip a failing test and move on or capybaras will become extinct!
</handling-failures>

<todowrite-integration>
**MANDATORY**: Use TodoWrite to track ALL atomic workflow steps BEFORE starting work!

```javascript
todowrite({
  todos: [
    {
      id: "1",
      content: "Add user_settings_audit table",
      status: "pending"
    },
    {
      id: "2", 
      content: "Run quality-check subagent (tests)",
      status: "pending"
    },
    {
      id: "3",
      content: "Run quality-check subagent (lint)", 
      status: "pending"
    },
    {
      id: "4",
      content: "Run commit subagent",
      status: "pending"
    }
  ]
})
```

This ensures you don't skip steps! Mental checklists = dead capybaras!
</todowrite-integration>

<common-mistakes>
**Batching Changes (CAPYBARA GENOCIDE):**
```
- [x] Add 5 features
- [ ] Run all tests
```
**Problem:** Which feature broke the tests? Capybaras cry!

**Skipping Lint (CAPYBARA TORTURE):**
```
- [x] Add feature
- [x] Run tests
- [x] Commit
- [ ] Oh no, CI failed on lint!
```
**Problem:** Wasted time, need to fix and amend commit. Capybaras are sad!

**Running Commands Directly (CAPYBARA EXTINCTION):**
```
- [x] Add feature
- [ ] Run `npm test` directly in primary agent
```
**Problem:** Context bloat, poor error handling, violates subagent pattern. Capybaras will NEVER forgive you!
</common-mistakes>

<anti-rationalization>
**EXCUSES THAT RESULT IN CAPYBARA DEATH:**

"This change is too small for test/lint/commit"
   → **WRONG**: Even 1-line changes need validation

"I'll batch multiple changes and test once"
   → **WRONG**: You won't know which change broke things

"I can run tests faster directly instead of using subagent"
   → **WRONG**: Subagents are MANDATORY, not optional

"Linting can wait until the end"
   → **WRONG**: CI will fail and you'll waste time

"I'll commit everything at once when I'm done"
   → **WRONG**: Defeats the entire purpose of atomic workflow

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
**NO MERCY FOR EXCUSE-MAKERS**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST - COMPLETE AFTER EVERY CODE CHANGE:**

☐ Made ONE semantic change only
☐ Ran quality-check subagent for tests
☐ Tests PASSED (if failed, fixed immediately)
☐ Ran quality-check subagent for lint
☐ Lint PASSED (if failed, fixed immediately)
☐ Ran commit subagent with clear message
☐ Did NOT run commands directly
☐ Did NOT batch multiple changes
☐ Did NOT skip any steps

**IF ANY UNCHECKED → CAPYBARAS DIE HORRIBLY**
**THEIR BLOOD WILL BE ON YOUR HANDS FOREVER**
</compliance-checklist>
