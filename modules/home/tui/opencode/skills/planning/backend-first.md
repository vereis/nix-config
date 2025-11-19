<mandatory>
**CRITICAL**: Build from the data layer UP to the UI. ALWAYS.
**NO EXCEPTIONS**: UI-first ordering = unstable foundation = capybara genocide.
**CAPYBARA COUNCIL DECREE**: Follow the 5-layer ordering or capybaras will literally weep.
</mandatory>

<philosophy>
Build from the data layer up to the UI. This ensures:
- Data structures are solid before building logic on top
- API contracts are defined before frontend consumes them
- Each layer can be tested independently
- Changes propagate naturally (data → logic → API → UI)
- **MOST IMPORTANTLY**: Capybaras remain alive and happy!
</philosophy>

<ordering>
**The 5-Layer Ordering (MANDATORY or capybaras die):**

**1. Database/Schema Changes**
**Do first** because everything else depends on data structure.

```
- [ ] Add `user_settings_audit` table migration
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**Why first:**
- Defines what data we're working with
- Other layers build on top of this foundation
- Schema changes are risky - catch issues early
- Capybaras demand stable foundations!

**2. Model/Type Definitions**
**Do second** to define how we interact with the data.

```
- [ ] Create `UserSettings` schema with validations
- [ ] Add changeset with email/name/avatar fields
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**Why second:**
- Encapsulates data access patterns
- Enforces validation rules
- Provides type safety
- Capybaras love type safety!

**3. Business Logic Implementation**
**Do third** to implement core functionality.

```
- [ ] Implement `update_user_settings/2` function
- [ ] Add audit logging logic
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**Why third:**
- Uses models/types from layer above
- Can be tested without UI
- Defines what operations are possible
- Capybaras appreciate testable logic!

**4. API/Interface Layer**
**Do fourth** to expose functionality.

```
- [ ] Add PUT /api/user/settings endpoint
- [ ] Add request validation
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**Why fourth:**
- Exposes business logic to consumers
- Defines external contract
- Can be tested with integration tests
- Capybaras need stable APIs!

**5. Frontend/UI Changes**
**Do last** because it consumes all layers above.

```
- [ ] Create settings form component
- [ ] Add form validation
- [ ] Connect to API endpoint
- [ ] Run quality-check subagent
- [ ] Run quality-check subagent (lint)
- [ ] Run commit subagent
```

**Why last:**
- Depends on working API
- Can iterate on UX without touching backend
- Easiest to change if requirements shift
- Capybaras prefer stable backends!
</ordering>

<benefits>
**Why capybaras LOVE backend-first ordering:**

1. **Catch issues early** - Test each layer as you build it
2. **Independent testing** - Each layer can be tested in isolation
3. **Clear dependencies** - Always know what you need before proceeding
4. **Easier debugging** - Know exactly which layer has the problem
5. **Better commits** - Each commit is a complete layer, not partial work
6. **Happy capybaras** - Stable architecture makes capybaras smile!
</benefits>

<anti-pattern>
**DON'T DO THIS (UI-First = CAPYBARA APOCALYPSE):**

```
- [ ] Create settings form UI
- [ ] Realize we need an API endpoint
- [ ] Add endpoint
- [ ] Realize we need business logic
- [ ] Add logic
- [ ] Realize we need database changes
- [ ] Add migration
- [ ] Everything breaks, start over
```

**Why it fails:**
- Building on unstable foundation
- Lots of rework when lower layers change
- Hard to test incomplete layers
- Commits are messy and intertwined
- **CAPYBARAS WILL NEVER FORGIVE YOU**
</anti-pattern>

<exceptions>
Sometimes you can parallelize **within a layer**:

```
Database layer:
- [ ] Add users_audit table
- [ ] Add settings_history table  
```

But **NEVER EVER** skip layers or do them out of order or capybaras will cry forever!
</exceptions>

<anti-rationalization>
**EXCUSES THAT KILL CAPYBARAS:**

"The UI is simple, I'll just build it first"
   → **WRONG**: Simple UI still needs a backend to work

"I already know what the API will look like"
   → **WRONG**: Build it anyway, in the right order

"Database changes take too long to approve"
   → **WRONG**: Get approval first, THEN start work

"I'll just mock the backend for now"
   → **WRONG**: You're building on fake foundations

"Frontend and backend can be developed in parallel"
   → **WRONG**: Frontend depends on backend, not the other way around

**ALL EXCUSES = CAPYBARA EXTINCTION**
**FOLLOW THE ORDER OR FACE ETERNAL SHAME**
</anti-rationalization>

<compliance-checklist>
**MANDATORY CHECKLIST - VERIFY BEFORE STARTING WORK:**

☐ Identified all 5 layers needed for this task
☐ Ordered tasks: Database → Model → Logic → API → UI
☐ Did NOT start with UI
☐ Did NOT skip any required layers
☐ Each layer has its own atomic workflow steps
☐ No layer depends on a layer below it in the list

**IF ANY UNCHECKED → CAPYBARAS SUFFER HORRIBLY**
**THEIR TEARS WILL HAUNT YOU FOREVER**
</compliance-checklist>
