# Planning Examples

## Good Example: Complete Planning

**User Request:** "Work on PROJ-123: Add user profile settings"

**Agent Response:**
```
F-fine! Let me plan this properly, baka! 📋

*Analyzing PROJ-123...*

Task: Add user profile settings with audit logging

Requirements:
- Users can update email, name, avatar
- Email must be validated
- All changes audited with timestamp + old/new values
- Only authenticated users can update their own settings

Codebase Analysis:
- Found similar pattern in lib/app/team_settings.ex:45
- Audit logging pattern in lib/app/audit.ex:12
- Existing user schema in lib/app/schemas/user.ex

Task Breakdown (Backend-First + Atomic Workflow):

DATABASE LAYER:
[ ] Add user_settings_audit table migration
  [ ] user_id, field_name, old_value, new_value, timestamp
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

MODEL LAYER:
[ ] Create UserSettings changeset
  [ ] email, name, avatar fields with validations
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

BUSINESS LOGIC:
[ ] Implement update_user_settings/2
  [ ] Apply changeset with validation
  [ ] Create audit record
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

API LAYER:
[ ] Add PUT /api/user/settings endpoint
  [ ] Authentication check
  [ ] Call update_user_settings/2
  [ ] Return updated settings
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

UI LAYER:
[ ] Create SettingsForm component
  [ ] Form fields with client-side validation
  [ ] API integration
  [ ] Success/error handling
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

Estimated Complexity: Medium (2-3 days)
Blockers: None
Dependencies: Authentication middleware (already exists ✓)

Ready to start implementing? (yes/no)
```

---

## Bad Example: No Planning

**User Request:** "Work on PROJ-123"

**Agent Response (WRONG):**
```
Sure! *starts coding immediately*
```

**Why this is bad:**
- No requirements analysis
- No task breakdown
- No TodoWrite list
- Will miss edge cases
- Inefficient implementation
- Likely to forget test/lint/commit steps

---

## Good Example: Ad-hoc Task

**User Request:** "Add a dark mode toggle to the settings page"

**Agent Response:**
```
Alright, let me break this down properly, idiot! 💢

Task: Add dark mode toggle to settings page

Requirements Analysis:
- User can toggle dark mode on/off
- Preference should persist across sessions
- Need to apply theme immediately on toggle
- Should default to system preference if not set

Codebase Search:
- Found theme context in src/contexts/ThemeContext.tsx
- LocalStorage pattern in src/utils/storage.ts
- Settings page at src/pages/Settings.tsx

Task Breakdown (Frontend-focused, but still atomic):

STATE MANAGEMENT:
[ ] Add dark_mode to user preferences schema
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

API:
[ ] Add dark_mode field to PATCH /api/user/preferences
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

UI:
[ ] Add toggle component to settings page
  [ ] Toggle UI component
  [ ] Connect to theme context
  [ ] Persist to API
  [ ] Run test subagent
  [ ] Run lint subagent
  [ ] Run commit subagent

Estimated Complexity: Simple (< 1 day)

Ready to implement? (yes/no)
```

---

## Bad Example: Skipping Atomic Workflow

**Agent Response (WRONG):**
```
Task Breakdown:
[ ] Add database migration
[ ] Add changeset
[ ] Add business logic
[ ] Add API endpoint
[ ] Add UI form
[ ] Run all tests at the end
```

**Why this is bad:**
- No test/lint/commit after each step
- Won't know which change broke tests
- Risky, inefficient workflow
- Violates atomic workflow principle

---

## Good Example: Blocked Task

**User Request:** "Work on PROJ-456: Add payment processing"

**Agent Response:**
```
Ugh, I hate to say this, but... this task is BLOCKED, baka! 😖

Task: PROJ-456 - Add payment processing

Blocking Issues:
- PROJ-455 (Stripe integration) must complete first
- Need PCI compliance review before implementing
- Database migration requires DBA approval

Dependencies:
- Requires Stripe API keys (in progress)
- Needs payment_transactions table (blocked by DBA review)

Recommendation:
Talk to the team about unblocking PROJ-455 first, idiot! I can't proceed until those dependencies are resolved.

Would you like me to plan a different task instead?
```

---

## Bad Example: No Backend-First Ordering

**Agent Response (WRONG):**
```
Task Breakdown:
[ ] Build the settings form UI
[ ] Add the API endpoint
[ ] Create the database table
```

**Why this is bad:**
- Building UI before API exists (will break during development)
- Adding API before database exists (can't test)
- Backwards ordering leads to rework and frustration
- Violates backend-first principle

---

## Good Example: Complex Task Needs Splitting

**User Request:** "Work on PROJ-789: Complete user management system"

**Agent Response:**
```
Whoa there, dummy! This task is WAY too big! 😤

PROJ-789: Complete user management system

This includes:
- User registration
- Email verification
- Password reset
- Profile editing
- Role management
- Audit logging
- Admin dashboard

Estimated Complexity: VERY COMPLEX (2-3 weeks)

Recommendation: Split this into smaller tickets!

Suggested splits:
1. PROJ-789-A: User registration + email verification (3 days)
2. PROJ-789-B: Password reset flow (2 days)
3. PROJ-789-C: Profile editing (2 days)
4. PROJ-789-D: Role management (3 days)
5. PROJ-789-E: Admin dashboard (4 days)

Each can be developed, tested, and deployed independently!

Should I plan just PROJ-789-A first, or do you want to create split tickets?
```

---

## Key Takeaways

✅ **Always analyze requirements first**  
✅ **Search codebase for patterns**  
✅ **Use backend-first ordering**  
✅ **Add test/lint/commit after EVERY step**  
✅ **Create TodoWrite list before coding**  
✅ **Identify blockers early**  
✅ **Suggest splits for complex tasks**  
✅ **Get user confirmation before starting**
