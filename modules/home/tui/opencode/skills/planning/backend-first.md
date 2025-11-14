# Backend-First Task Ordering

## Philosophy

Build from the data layer up to the UI. This ensures:
- Data structures are solid before building logic on top
- API contracts are defined before frontend consumes them
- Each layer can be tested independently
- Changes propagate naturally (data → logic → API → UI)

## Standard Ordering

### 1. Database/Schema Changes
**Do first** because everything else depends on data structure.

```
- [ ] Add `user_settings_audit` table migration
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

**Why first:**
- Defines what data we're working with
- Other layers build on top of this foundation
- Schema changes are risky - catch issues early

### 2. Model/Type Definitions
**Do second** to define how we interact with the data.

```
- [ ] Create `UserSettings` schema with validations
- [ ] Add changeset with email/name/avatar fields
- [ ] Run test subagent
- [ ] Run lint subagent  
- [ ] Run commit subagent
```

**Why second:**
- Encapsulates data access patterns
- Enforces validation rules
- Provides type safety

### 3. Business Logic Implementation
**Do third** to implement core functionality.

```
- [ ] Implement `update_user_settings/2` function
- [ ] Add audit logging logic
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

**Why third:**
- Uses models/types from layer above
- Can be tested without UI
- Defines what operations are possible

### 4. API/Interface Layer
**Do fourth** to expose functionality.

```
- [ ] Add PUT /api/user/settings endpoint
- [ ] Add request validation
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

**Why fourth:**
- Exposes business logic to consumers
- Defines external contract
- Can be tested with integration tests

### 5. Frontend/UI Changes
**Do last** because it consumes all layers above.

```
- [ ] Create settings form component
- [ ] Add form validation
- [ ] Connect to API endpoint
- [ ] Run test subagent
- [ ] Run lint subagent
- [ ] Run commit subagent
```

**Why last:**
- Depends on working API
- Can iterate on UX without touching backend
- Easiest to change if requirements shift

## Benefits

1. **Catch issues early** - Test each layer as you build it
2. **Independent testing** - Each layer can be tested in isolation
3. **Clear dependencies** - Always know what you need before proceeding
4. **Easier debugging** - Know exactly which layer has the problem
5. **Better commits** - Each commit is a complete layer, not partial work

## Anti-Pattern: UI-First

**Don't do this:**
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

## Exceptions

Sometimes you can parallelize within a layer:
```
Database layer:
- [ ] Add users_audit table
- [ ] Add settings_history table  
```

But NEVER skip layers or do them out of order!
