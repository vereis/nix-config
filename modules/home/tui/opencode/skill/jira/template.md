# JIRA Ticket Template

**MANDATORY**: This is the SINGLE SOURCE OF TRUTH for JIRA ticket structure.

## Template Structure

All JIRA tickets **MUST** follow this structure:

```markdown
**Description:**
  - As a [specific actor/role], I want [feature] so that [measurable benefit].
  - As a [actor2], I want [feature2] so that [benefit2].

**Scope:**
  - [User-facing pages/components with URLs, e.g., Aged AR Report at localhost:3000/financials/aged_ar/]
  - [**Out of Scope:** items explicitly excluded if helpful]

**Acceptance Criteria:**
\`\`\`gherkin
# Happy Path
Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]

# Edge Cases (ALWAYS include!)
Given [edge condition: empty state, null values, max limits]
  When [action]
  Then [graceful handling]

# Error Scenarios (ALWAYS include!)
Given [error condition: invalid input, permissions]
  When [triggering action]
  Then [appropriate error handling and user feedback]
\`\`\`

**Dev Notes:** (Optional - high-level pointers ONLY)
  - [Relevant file paths with line numbers, e.g., src/medications.ex:142]
  - [Similar implementations for reference]
  - [Important constants/config to be aware of]

**Questions:** (Optional - ONLY genuine unknowns that BLOCK progress)
  - Make reasonable decisions instead of asking
  - Document decisions in Dev Notes
  - If questions needed, tag specific people (@username)
```

## Section Guidelines

### Description

**Format:** "As a [actor], I want [feature] so that [benefit]."

**Actors (MANDATORY):**
- Search codebase for roles (seed scripts, permission definitions, auth modules)
- Use **SPECIFIC** names: "clinic staff member", "practice manager", "veterinarian"
- **NEVER** use generic "user"
- List all actors if multiple benefit

**Benefits:**
- Must be **observable and testable**
- Focus on **OUTCOME**, not feature
- ✅ GOOD: "so that I can quickly identify overdue payments"
- ❌ BAD: "so that it works better" / "because it's broken"

### Scope

**Purpose:** Define **WHERE** work happens, **NOT HOW**.

**Include:**
- Page names with **FULL URLs** (e.g., "Patient Profile at localhost:3000/patients/:id")
- Components affected (e.g., "Medication list component")
- External integrations (e.g., "Stripe payment webhook")

**NEVER include:**
- Database tables/migrations
- GraphQL schema changes
- Functions/modules/implementation details

**Examples:**
- ✅ GOOD: "Pharmacy whiteboard (localhost:3000/pharmacy)"
- ❌ BAD: "Update the medications table"
- ❌ BAD: "Modify MedicationService.prescribe/2 function"

### Acceptance Criteria

**Format:** Gherkin syntax (Given/When/Then/And/Or) - **NO EXCEPTIONS**

**ALWAYS cover:**
1. **Happy Path** - Normal user flow
2. **Edge Cases** - Empty states, null values, max limits
3. **Error Scenarios** - Invalid input, permissions, failures

**Focus on observable behavior:**
- ✅ What user sees/does, what system displays
- ❌ Database operations, implementation details

**Examples:**

✅ **GOOD:**
```gherkin
Scenario: Prescribing draft medication
  Given a medication exists with `draft` status on the patient's medication tab
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Scenario: Empty state shows helpful message
  Given no medications exist for the patient
  When the user opens the medication tab
  Then they should see an empty state message
  And a "Add Medication" button

Scenario: Validation error prevents prescribing incomplete medication
  Given a user attempts to prescribe a medication
  When the medication has missing required fields
  Then they should see a validation error
  And the medication should remain in draft status
```

❌ **BAD:**
```gherkin
Scenario: Prescribing medications
  Given the user wants to prescribe a medication
  When they click prescribe
  Then it should work correctly
  And update the database
```

### Dev Notes

**Purpose:** High-level pointers ONLY. Most tickets don't need this.

**Include:**
- Relevant file paths with line numbers
- Similar implementations to reference
- Important constants/config values

**NEVER include:**
- Database migrations (belongs in PR)
- GraphQL schema changes (belongs in PR)
- Step-by-step implementation instructions

**Examples:**

✅ **GOOD:**
```markdown
**Dev Notes:**
- See `src/medications.ex:142` for existing prescription logic
- Similar pattern used in lab results (src/lab_results.ex:89)
- Invoice sync happens via MedicationInvoiceWorker background job
```

❌ **BAD:**
```markdown
**Dev Notes:**
1. Add `draft` column to medications table
2. Create migration
3. Update MedicationsContext.create_medication/1
```

### Questions

**Purpose:** ONLY genuine unknowns that **BLOCK progress**.

**Guidelines:**
- Make **DECISIONS** instead of asking
- Document decisions in Dev Notes
- User reviews and corrects during draft phase
- Tag specific people if questions needed (@username)

**Examples:**

✅ **GOOD (only if absolutely needed):**
```markdown
**Questions:**
- @security-team: Should clinic staff modify historical medications, or only admins?
- @product: Do we need bulk prescription of multiple medications?
```

❌ **BAD (make decisions):**
```markdown
**Questions:**
- Should we add a loading spinner? [YES - just do it]
- Should we validate the dosage? [YES - ALWAYS validate input]
```

## Compliance Checklist

**MANDATORY before creating ANY ticket:**

- [ ] Used **SPECIFIC ACTORS** (not "user")
- [ ] Benefits are **OBSERVABLE AND TESTABLE**
- [ ] Scope lists **WHERE** (pages/URLs), not HOW (code/DB)
- [ ] Acceptance criteria uses **GHERKIN FORMAT**
- [ ] Included **HAPPY PATH** scenarios
- [ ] Included **EDGE CASES** (empty, null, max)
- [ ] Included **ERROR SCENARIOS** (validation, permissions)
- [ ] No implementation details in acceptance criteria
- [ ] Dev Notes are **HIGH-LEVEL ONLY** (if included)
- [ ] Made **DECISIONS** instead of questions (if possible)
