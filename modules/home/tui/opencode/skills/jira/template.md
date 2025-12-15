# JIRA Ticket Template

## Mandatory

**MANDATORY**: This is the SINGLE SOURCE OF TRUTH for JIRA ticket creation.
**CRITICAL**: NEVER create tickets without consulting this file FIRST.
**NO EXCEPTIONS**: Even with complete requirements, you MUST reference this template.

## Template Structure

All JIRA tickets **MUST** follow this exact structure:

```markdown
**Description:**
  - As a [specific actor/role], I want [feature] so that [measurable benefit].
  - As a [actor2], I want [feature2] so that [benefit2].
  ...

**Scope:**
  - [High level user-facing pages/components affected, with URLs if applicable e.g. Aged AR Report at localhost:3000/financials/aged_accounts_receivable/]
  - [Call out anything NOT in scope if helpful e.g. **Out of Scope:** changes to underlying ledger entries]
  ...

**Acceptance Criteria:**
\`\`\`gherkin
# Happy Path
Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]
  Or [alternative outcomes]

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

  **NEVER include:**
  - Database migrations
  - GraphQL schema changes
  - Low-level implementation steps
  - These belong in the PR, not the ticket!

**Questions:** (Optional - ONLY genuine unknowns that BLOCK progress)
  - Make reasonable decisions instead of asking
  - Document decisions in Dev Notes
  - User will review and correct during draft phase
  - If you DO include questions, tag specific people
```

**DO NOT** add other sections unless requested by user.

## Section Guidance

### Description

**Format:** "As a [actor], I want [feature] so that [benefit]."

**Finding Actors (MANDATORY):**
- **PROACTIVELY** search for roles in tickets or codebase
  - Look for seed scripts (`priv/repo/seeds.exs`)
  - Search for permission definitions
  - Check role definitions in auth modules
- Use **SPECIFIC** names: "clinic staff member", "practice manager", "veterinarian", "shopper", "admin"
- **NEVER** use generic "user"
- If multiple actors benefit, **LIST ALL OF THEM**

**Features and Benefits (MANDATORY):**
- Benefits must be **observable and testable**
- Focus on the **OUTCOME**, not the feature itself
- **GOOD**: "so that I can quickly identify overdue payments"
- **BAD**: "so that it works better"
- **BAD**: "because it's broken"

**Examples:**
- ✅ GOOD: "As a clinic staff member, I want draft medications to sync onto invoices so that invoices are accurate."
- ❌ BAD: "As a user, I want the medication system to work properly."

### Scope

**Purpose:** Define **WHERE** work happens, **NOT HOW** it happens.

**What to Include (MANDATORY):**
- Page names with **FULL URLs** (e.g., "Patient Profile at localhost:3000/patients/:id")
- Components affected (e.g., "Medication list component")
- User-facing areas (e.g., "Pharmacy whiteboard")
- External integrations (e.g., "Stripe payment webhook")

**NEVER INCLUDE:**
- Database tables or migrations
- GraphQL schema changes
- Specific functions or modules
- Implementation details
- ANY technical "how" details

**Call out what's explicitly NOT included:**
```markdown
**Scope:**
- Aged AR Report (localhost:3000/financials/aged_accounts_receivable/)
- Invoice detail page

**Out of Scope:**
- Changes to underlying ledger entries
- Historical invoice modifications
```

**Examples:**
- ✅ GOOD: "Patient's medication tab"
- ✅ GOOD: "Pharmacy whiteboard (localhost:3000/pharmacy)"
- ✅ GOOD: "Patient encounters (localhost:3000/patients/:id/encounters/:encounter_id)"
- ❌ BAD: "Update the medications table"
- ❌ BAD: "Change the prescribe_medication GraphQL mutation"
- ❌ BAD: "Modify MedicationService.prescribe/2 function"

**NEVER** duplicate acceptance criteria, dev notes, or description in this section.

### Acceptance Criteria

**Format:** Gherkin syntax (Given/When/Then/And/Or) - **NO EXCEPTIONS**

**ALWAYS cover these scenarios:**
1. **Happy Path** - Normal user flow
2. **Edge Cases** - Empty states, null values, max limits
3. **Error Scenarios** - Invalid input, permissions, failures

**Focus ONLY on observable behavior:**
- ✅ What the user sees/does
- ✅ What the system displays
- ❌ Database operations
- ❌ Implementation details
- ❌ Impossible edge cases

**Example Template:**
```gherkin
Scenario: Description of what's being tested
  Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]
  Or [alternative outcomes]
```

**Be SPECIFIC about state:**
```gherkin
Scenario: Prescribing a draft medication
  Given a medication exists with `draft` status
  When the medication is prescribed
  Then its status should change to `active`
```

**Cover alternatives:**
```gherkin
Scenario: Adding medication to invoice via different methods
  Given a user creates a medication
  When they set the status to "prescribed"
  Or they click the "Prescribe" button
  Then it should be added to an invoice
```

**Handle errors gracefully:**
```gherkin
Scenario: Validation error prevents prescribing incomplete medication
  Given a user attempts to prescribe a medication
  When the medication has missing required fields
  Then they should see a validation error
  And the medication should remain in draft status
```

**ALWAYS include edge cases:**
```gherkin
Scenario: Empty state shows helpful message
  Given no medications exist for the patient
  When the user opens the medication tab
  Then they should see an empty state message
  And a "Add Medication" button

Scenario: Null dosage prevents prescription
  Given a medication exists with no dosage
  When the user attempts to prescribe it
  Then they should see a validation error

Scenario: Warning displayed for high medication count
  Given a patient has 100 active medications
  When the user attempts to add another
  Then the system should allow it
  And display a warning about review
```

**NEVER include:**
- Implementation details ("call the prescribe_medication mutation")
- Database operations ("insert into medications table")
- Code-level logic ("set the drafted_at field to nil")

**GOOD Examples:**
```gherkin
Scenario: Prescribing draft medication adds to invoice
  Given a medication exists with `draft` status on the patient's medication tab
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Scenario: External or historical medications removed from invoice
  Given a medication has the `active` status and is on an invoice
  When that medication is marked either `is external` or `is historical`
  And that invoice is not finalized
  Then it should be removed from the invoice
```

**BAD Examples:**
```gherkin
Scenario: Prescribing medications
  Given the user wants to prescribe a medication
  When they click prescribe
  Then it should work correctly
  And update the database
```

### Dev Notes

**Purpose:** High-level pointers ONLY. **Most tickets don't need this section.**

**When to Include:**
- Relevant file paths with line numbers (for context)
- Similar implementations to reference
- Important constants/config values
- Non-obvious technical constraints

**What to Include:**
```markdown
**Dev Notes:**
- See `src/medications.ex:142` for existing prescription logic
- Similar pattern used in lab results (src/lab_results.ex:89)
- Default medication status is defined in config/config.exs:MEDICATION_STATUSES
- Invoice sync happens via MedicationInvoiceWorker background job
```

**What to NEVER Include:**
- Database migrations (belongs in PR)
- GraphQL schema changes (belongs in PR)
- Step-by-step implementation instructions
- Low-level technical decisions

**GOOD Examples:**
```markdown
**Dev Notes:**
- Existing draft workflow in src/orders.ex:234 can be used as reference
- Invoice sync logic lives in InvoiceSyncWorker
- Default timezone set in priv/repo/seeds.exs line 12
```

**BAD Examples:**
```markdown
**Dev Notes:**
1. Add `draft` column to medications table (boolean, default: true)
2. Create migration to add the column
3. Update MedicationsContext.create_medication/1 to set draft=true
4. Add GraphQL mutation update_medication_status
5. Update frontend MedicationForm component
```

### Questions

**Purpose:** ONLY genuine unknowns that **BLOCK progress**.

**Guidelines (MANDATORY):**
- Make reasonable **DECISIONS** instead of asking questions
- Document decisions in Dev Notes
- User will review and correct during draft phase
- If you DO include questions, **TAG SPECIFIC PEOPLE** (@username)

**When Questions Are Appropriate (RARE):**
```markdown
**Questions:**
- @product-team: Should historical medications sync to new invoices or only existing ones?
- @john: Is there a maximum limit for active medications per patient?
```

**When to Make DECISIONS Instead (ALWAYS):**

**Scenario:** "Should we show a confirmation dialog?"
**Decision:** Add it to acceptance criteria as expected behavior:
```gherkin
Scenario: Confirmation dialog warns about finalized invoice impact
  Given a user clicks "Delete Medication"
  When the medication is on a finalized invoice
  Then they should see a confirmation dialog
  And the dialog should explain the invoice impact
```

**Scenario:** "What should the error message say?"
**Decision:** Specify in acceptance criteria:
```gherkin
Scenario: Missing dosage shows specific error
  Given a user attempts to prescribe a medication without dosage
  When they submit the form
  Then they should see an error: "Cannot prescribe medication without dosage"
```

**GOOD Examples (only if ABSOLUTELY NEEDED):**
```markdown
**Questions:**
- @security-team: Should clinic staff be able to modify historical medications, or only admins?
- @product: Do we need to support bulk prescription of multiple medications?
```

**BAD Examples (make DECISIONS instead):**
```markdown
**Questions:**
- Should we add a loading spinner? [YES - just do it, basic UX]
- What color should the button be? [Use existing design system]
- Should we validate the dosage? [YES - ALWAYS validate input]
```

## Complete Example

```markdown
**Description:**
- As a clinic staff member, I don't want draft medications to sync onto invoices.
- As a clinic staff member, I want prescribed medications to sync onto invoices.

**Scope:**
- Patient's medication tab
- Pharmacy whiteboard
- Patient encounters

**Acceptance Criteria:**
\`\`\`gherkin
Scenario: Creating medication from medication tab starts as draft
  Given a user orders a medication on the patient's medication tab
  When the medication is created
  Then it should be created with `draft` status
  And it should not appear on any invoice

Scenario: Prescribing draft medication from medication tab
  Given a medication exists with `draft` status on the patient's medication tab
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Scenario: Creating medication during encounter starts as draft
  Given a user orders a medication during an encounter
  When the medication is created
  Then it should be created with `draft` status
  And it should not appear on any invoice

Scenario: Prescribing draft medication during encounter
  Given a medication exists with `draft` status during an encounter
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Scenario: Prescribing ready medication from pharmacy whiteboard
  Given a medication is marked `ready` on the pharmacy whiteboard
  When it is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Scenario: Marking medication as external or historical removes from invoice
  Given a medication has the `active` status and is on an invoice
  When that medication is marked either `is external` or `is historical`
  And that invoice is not finalized
  Then it should be removed from the invoice

Scenario: Unmarking external or historical re-adds to invoice
  Given a medication has the `active` status and is marked either `is external` or `is historical`
  When that medication is updated so that it's no longer marked `is external` or `is historical`
  And that invoice is not finalized
  Then it should be re-added to an invoice
\`\`\`

**Additional Notes:**
- This needs to be called out in release notes because this is a big change to existing UX.
- Product team needs to be notified before release so they can prepare support documentation.
```

## Compliance Checklist

**MANDATORY - Complete before creating ANY ticket:**

☐ Used **SPECIFIC ACTORS** (not "user")
☐ Benefits are **OBSERVABLE AND TESTABLE**
☐ Scope lists **WHERE** (pages/URLs), not HOW (code/DB)
☐ Acceptance criteria uses **GHERKIN FORMAT** (Given/When/Then)
☐ Included **HAPPY PATH** scenarios
☐ Included **EDGE CASES** (empty, null, max)
☐ Included **ERROR SCENARIOS** (validation, permissions)
☐ No implementation details in acceptance criteria
☐ Dev Notes are **HIGH-LEVEL ONLY** (if included)
☐ Made **DECISIONS** instead of asking questions (if possible)
☐ Tagged specific people for **BLOCKING QUESTIONS** (if needed)

**IF ANY UNCHECKED THEN TICKET QUALITY SUFFERS**

## Anti-Rationalization

**THESE EXCUSES NEVER APPLY:**

"Ticket is too simple for all sections"
**WRONG**: Even simple tickets need proper structure

"I'll skip Dev Notes, it's obvious"
**WRONG**: If obvious, you don't need Dev Notes, but you need other sections

"User knows what they want"
**WRONG**: User knows GOAL, you define STRUCTURE

"I don't need acceptance criteria for a bug"
**WRONG**: Bugs ESPECIALLY need acceptance criteria to verify fix

"I'll use 'user' because I don't know specific role"
**WRONG**: SEARCH for roles in codebase FIRST (consult research.md)

"Scope is obvious from description"
**WRONG**: Make it EXPLICIT. Add URLs. Be SPECIFIC.

"I'll ask questions instead of making decisions"
**WRONG**: Make DECISIONS. Document them. User corrects if needed.

"Edge cases are obvious, don't need to list"
**WRONG**: EXPLICIT > IMPLICIT. Always include edge cases.

**NO EXCEPTIONS**
