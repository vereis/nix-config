# Task Breakdown Process

## Overview

This document describes how to analyze requirements and break them down into actionable tasks using the backend-first + atomic workflow pattern.

## Step 1: Gather Context

### For JIRA Tickets
```bash
# View ticket details
jira issue view PROJ-123

# Check for related tickets
jira issue view PROJ-123 --plain | grep -E "(Blocks|Relates|Epic)"

# View linked PRs if mentioned
gh pr view 456
```

### For GitHub Issues
```bash
# View issue details
gh issue view 123

# Check for related issues
gh issue view 123 --json body
```

### For Ad-hoc Tasks
Ask clarifying questions:
- What's the user-facing goal?
- What's the acceptance criteria?
- Are there any constraints or dependencies?
- What's the scope (what's included, what's NOT)?

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

```bash
# Find similar implementations
rg "similar_feature" --type elixir

# Locate relevant files
rg "UserSettings" --files-with-matches

# Check existing tests for patterns
cat test/user_settings_test.exs
```

**Identify:**
- Existing patterns to follow
- Similar features to reference
- Test patterns to replicate
- Code conventions to match

## Step 4: Break Down Using Backend-First

Apply the 5-layer breakdown:

### 1. Database/Schema Layer
What data needs to be stored? What tables/columns?
```
- [ ] Add user_settings_audit table
  - [ ] Migration with user_id, changes (jsonb), timestamp
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

### 2. Model/Type Layer
How do we represent and validate this data?
```
- [ ] Create UserSettings schema
  - [ ] Define Ecto schema with fields
  - [ ] Add changeset with validations
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

### 3. Business Logic Layer
What operations are possible? What rules apply?
```
- [ ] Implement update_user_settings/2
  - [ ] Core update logic
  - [ ] Audit logging
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

### 4. API/Interface Layer
How do external consumers interact with this?
```
- [ ] Add PUT /api/user/settings endpoint
  - [ ] Request validation
  - [ ] Response formatting
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

### 5. Frontend/UI Layer
What does the user see and interact with?
```
- [ ] Create settings form component
  - [ ] Form fields and validation
  - [ ] API integration
  - [ ] Run test subagent
  - [ ] Run lint subagent
  - [ ] Run commit subagent
```

## Step 5: Add Atomic Workflow Steps

**CRITICAL**: After EVERY implementation task, add:
```
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

This is NON-NEGOTIABLE! Each semantic change must be tested, linted, and committed.

## Step 6: Identify Dependencies and Blockers

**Check for:**
- Blocking tickets that must complete first
- Required API endpoints that don't exist yet
- Missing infrastructure or services
- Database migrations that need approval

**If blocked:**
```
B-baka! This task is blocked! 😖

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
- Consider splitting into multiple tickets!

## Step 8: Create TodoWrite List

**MANDATORY**: Use TodoWrite to capture ALL tasks BEFORE starting implementation!

## Step 9: Present Plan to User

Show the complete breakdown:
```
F-fine! Here's your battle plan, baka! 📋

Task: PROJ-123 - Add user settings with audit logging

Requirements:
- Users can update email, name, avatar
- All changes must be audited
- Validation on email format

Task Breakdown (Backend-First + Atomic Workflow):

Database Layer:
[ ] Add user_settings_audit table
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

Model Layer:
[ ] Create UserSettings schema with validations
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

... (rest of layers)

Estimated complexity: Medium
Blockers: None
Dependencies: Requires auth middleware (already exists)

Ready to start? (yes/no)
```

## Common Mistakes

### ❌ Skipping Planning
```
User: "Work on PROJ-123"
Agent: "Sure!" *starts coding immediately*
```

**Problem:** No clear plan, will miss requirements, inefficient implementation

### ❌ Not Using TodoWrite
```
Agent: "I'll do steps 1-5 in my head"
*Forgets step 3, skips tests*
```

**Problem:** Steps get skipped, no tracking of progress

### ❌ Forgetting Atomic Workflow
```
[ ] Add all features
[ ] Run tests at the end
```

**Problem:** Don't know which change broke tests

### ❌ UI-First Planning
```
[ ] Build the form
[ ] Add the API
[ ] Add the database
```

**Problem:** Building on unstable foundation, lots of rework

## Best Practices

✅ **Always start with requirements analysis**  
✅ **Search codebase for patterns to follow**  
✅ **Use backend-first ordering religiously**  
✅ **Add test/lint/commit after EVERY task**  
✅ **Create TodoWrite list before coding**  
✅ **Present plan to user for confirmation**  
✅ **Be proactive - don't wait to be asked to plan!**
