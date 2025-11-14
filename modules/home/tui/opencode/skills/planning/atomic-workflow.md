# Atomic Workflow Pattern

## Philosophy

After EACH semantic code change, immediately run:
1. Tests
2. Lints/formatters
3. Commit (if both pass)

This catches issues **immediately** instead of at the end when everything's broken!

## The Pattern

```
[ ] Implement feature X
  [ ] Write the code
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent
```

**CRITICAL:** ALWAYS use subagents! Primary agent MUST delegate to test/lint/commit subagents, NEVER run commands directly!

## Why This Works

### ✅ Immediate Feedback
```
- [ ] Add UserSettings schema
  - [x] Define schema
  - [x] Run test subagent → PASS
  - [x] Run lint subagent → FAIL (formatting issue)
  - [x] Fix formatting
  - [x] Run lint subagent → PASS
  - [x] Run commit subagent
```

You know **immediately** that your schema works and is properly formatted.

### ❌ Without Atomic Workflow
```
- [x] Add UserSettings schema
- [x] Add update_user_settings/2 function
- [x] Add API endpoint
- [x] Add UI form
- [ ] Run tests → 47 FAILURES across all layers
- [ ] ??? Which layer broke? Where did it break? When did it break?
```

You have NO IDEA where things went wrong!

## Benefits

1. **Pinpoint failures** - Know exactly which change broke things
2. **Clean history** - Each commit is tested and linted
3. **Easier review** - Reviewers see logical, working increments
4. **Confidence** - Know each step is solid before moving on
5. **No "fix later"** - Issues addressed immediately

## Semantic Changes

A semantic change is ONE logical unit of work:

**Good (one semantic change):**
```
- [ ] Add email validation to UserSettings
  - [ ] Add validation rule
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

**Bad (multiple semantic changes):**
```
- [ ] Add email validation AND name validation AND avatar upload
```

Split this into THREE separate atomic workflow cycles!

## Subagent Delegation

**MANDATORY:** Always use subagents for test/lint/commit!

**✅ CORRECT:**
```
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

**❌ WRONG:**
```
- [ ] Run `mix test`
- [ ] Run `mix format`
- [ ] Run `git commit`
```

**Why?** 
- Subagents handle context management
- They fail fast and return clean output
- Primary agent doesn't get bloated with test output
- Proper error handling and reporting

## Examples

### Example 1: Database Migration

```
[ ] Add user_settings_audit table
  [ ] Create migration file
  [ ] Define schema with columns
  [ ] Run test subagent (migration runs successfully)
  [ ] Run lint subagent (formatting check)
  [ ] Run commit subagent
```

**Result:** One commit with working, tested migration

### Example 2: Business Logic

```
[ ] Implement update_user_settings/2 function
  [ ] Write function with changeset
  [ ] Add audit logging
  [ ] Run test subagent (unit tests pass)
  [ ] Run lint subagent (code formatted correctly)
  [ ] Run commit subagent
```

**Result:** One commit with tested business logic

### Example 3: Multiple Small Changes

```
[ ] Add email validation
  [ ] Add validation rule to changeset
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

[ ] Add name validation
  [ ] Add validation rule to changeset
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent
```

**Result:** TWO commits, each tested and working

This is BETTER than one big commit with both changes!

## When Tests Fail

If tests fail during the atomic workflow:

1. **Fix the issue immediately**
2. **Re-run test subagent**
3. **Don't move to next task until passing**

```
[ ] Add UserSettings schema
  [ ] Define schema
  [ ] Run test subagent → FAIL
  [ ] Fix validation error
  [ ] Run test subagent → PASS
  [ ] Run lint subagent → PASS
  [ ] Run commit subagent
```

## TodoWrite Integration

**MANDATORY:** Use TodoWrite to track ALL atomic workflow steps BEFORE starting work!

```
todowrite({
  todos: [
    {
      id: "1",
      content: "Add user_settings_audit table",
      status: "pending"
    },
    {
      id: "2", 
      content: "Run test subagent",
      status: "pending"
    },
    {
      id: "3",
      content: "Run lint subagent", 
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

This ensures you don't skip steps!

## Common Mistakes

### ❌ Batching Changes
```
- [x] Add 5 features
- [ ] Run all tests
```

**Problem:** Which feature broke the tests?

### ❌ Skipping Lint
```
- [x] Add feature
- [x] Run tests
- [x] Commit
- [ ] Oh no, CI failed on lint!
```

**Problem:** Wasted time, need to fix and amend commit

### ❌ Running Commands Directly
```
- [x] Add feature
- [ ] Run `npm test` directly in primary agent
```

**Problem:** Context bloat, poor error handling, violates subagent pattern
