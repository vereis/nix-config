# JIRA Ticket Section Guidance

## Description

**Format:** "As a [actor], I want [feature] so that [benefit]."

### Finding Actors
- Check `priv/repo/seeds.exs` for real roles
- Look at permission definitions in the codebase
- Use specific names: "clinic staff member", "practice manager", "veterinarian"
- **NEVER** use generic "user"

### Measurable Benefits
- Should be observable and testable
- Focus on the outcome, not the feature
- Examples:
  - ✅ "so that I can quickly identify overdue payments"
  - ❌ "so that it works better"

### Multiple User Stories
If multiple actors benefit, list all of them:
```markdown
**Description:**
- As a veterinarian, I want to see medication history so that I can make informed prescribing decisions.
- As a clinic staff member, I want to track medication inventory so that I know when to reorder.
```

### Examples

**GOOD:**
```markdown
**Description:**
- As a clinic staff member, I don't want draft medications to sync onto invoices.
- As a clinic staff member, I want prescribed medications to sync onto invoices.
```

**BAD:**
```markdown
**Description:**
- As a user, I want the medication system to work properly.
```

---

## Scope

**Purpose:** Define WHERE work happens, not HOW.

### What to Include
- Page names with URLs (e.g., "Patient Profile at localhost:3000/patients/:id")
- Components affected (e.g., "Medication list component")
- User-facing areas (e.g., "Pharmacy whiteboard")
- External integrations (e.g., "Stripe payment webhook")

### What NOT to Include
- Database tables or migrations
- GraphQL schema changes
- Specific functions or modules
- Implementation details

### Out of Scope
Call out what's explicitly NOT included:
```markdown
**Scope:**
- Aged AR Report (localhost:3000/financials/aged_accounts_receivable/)
- Invoice detail page

**Out of Scope:**
- Changes to underlying ledger entries
- Historical invoice modifications
```

### Examples

**GOOD:**
```markdown
**Scope:**
- Patient's medication tab
- Pharmacy whiteboard (localhost:3000/pharmacy)
- Patient encounters (localhost:3000/patients/:id/encounters/:encounter_id)
```

**BAD:**
```markdown
**Scope:**
- Update the medications table
- Change the prescribe_medication GraphQL mutation
- Modify MedicationService.prescribe/2 function
```

---

## Acceptance Criteria

**Format:** Gherkin syntax (Given/When/Then)

### Must Include
1. **Happy Path** - Normal user flow
2. **Edge Cases** - Empty states, null values, max limits
3. **Error Scenarios** - Invalid input, permissions, failures

### Gherkin Structure

```gherkin
Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]
  Or [alternative outcomes]
```

### Writing Good Criteria

**Be specific about state:**
```gherkin
Given a medication exists with `draft` status
  When the medication is prescribed
  Then its status should change to `active`
```

**Cover alternatives:**
```gherkin
Given a user creates a medication
  When they set the status to "prescribed"
  Or they click the "Prescribe" button
  Then it should be added to an invoice
```

**Handle errors gracefully:**
```gherkin
Given a user attempts to prescribe a medication
  When the medication has missing required fields
  Then they should see a validation error
  And the medication should remain in draft status
```

### Edge Cases Examples

```gherkin
# Empty State
Given no medications exist for the patient
  When the user opens the medication tab
  Then they should see an empty state message
  And a "Add Medication" button

# Null Values
Given a medication exists with no dosage
  When the user attempts to prescribe it
  Then they should see a validation error

# Max Limits
Given a patient has 100 active medications
  When the user attempts to add another
  Then the system should allow it
  And display a warning about review
```

### What NOT to Include
- Implementation details ("call the prescribe_medication mutation")
- Database operations ("insert into medications table")
- Code-level logic ("set the drafted_at field to nil")

### Examples

**GOOD:**
```gherkin
Given a medication exists with `draft` status on the patient's medication tab
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Given a medication has the `active` status and is on an invoice
  When that medication is marked either `is external` or `is historical`
  And that invoice is not finalized
  Then it should be removed from the invoice
```

**BAD:**
```gherkin
Given the user wants to prescribe a medication
  When they click prescribe
  Then it should work correctly
  And update the database
```

---

## Dev Notes

**Purpose:** High-level pointers ONLY. Most tickets don't need this section.

### When to Include
- Relevant file paths with line numbers (for context)
- Similar implementations to reference
- Important constants/config values
- Non-obvious technical constraints

### What to Include

```markdown
**Dev Notes:**
- See `src/medications.ex:142` for existing prescription logic
- Similar pattern used in lab results (src/lab_results.ex:89)
- Default medication status is defined in config/config.exs:MEDICATION_STATUSES
- Invoice sync happens via MedicationInvoiceWorker background job
```

### What NEVER to Include
- Database migrations (belongs in PR)
- GraphQL schema changes (belongs in PR)
- Step-by-step implementation instructions
- Low-level technical decisions

### Examples

**GOOD:**
```markdown
**Dev Notes:**
- Existing draft workflow in src/orders.ex:234 can be used as reference
- Invoice sync logic lives in InvoiceSyncWorker
- Default timezone set in priv/repo/seeds.exs line 12
```

**BAD:**
```markdown
**Dev Notes:**
1. Add `draft` column to medications table (boolean, default: true)
2. Create migration to add the column
3. Update MedicationsContext.create_medication/1 to set draft=true
4. Add GraphQL mutation update_medication_status
5. Update frontend MedicationForm component
```

---

## Questions

**Purpose:** ONLY genuine unknowns that BLOCK progress.

### Guidelines
- Make reasonable decisions instead of asking
- Document decisions in Dev Notes
- User will review and correct during draft phase
- If you DO include questions, tag specific people

### When Questions Are Appropriate

```markdown
**Questions:**
- @product-team: Should historical medications sync to new invoices or only existing ones?
- @john: Is there a maximum limit for active medications per patient?
```

### When to Make Decisions Instead

**Scenario:** "Should we show a confirmation dialog?"
**Decision:** Add it to acceptance criteria as the expected behavior:
```gherkin
Given a user clicks "Delete Medication"
  When the medication is on a finalized invoice
  Then they should see a confirmation dialog
  And the dialog should explain the invoice impact
```

**Scenario:** "What should the error message say?"
**Decision:** Specify in acceptance criteria:
```gherkin
Then they should see an error: "Cannot prescribe medication without dosage"
```

### Examples

**GOOD (rare cases):**
```markdown
**Questions:**
- @security-team: Should clinic staff be able to modify historical medications, or only admins?
- @product: Do we need to support bulk prescription of multiple medications?
```

**BAD (make decisions instead):**
```markdown
**Questions:**
- Should we add a loading spinner? [YES - just do it]
- What color should the button be? [Use existing design system]
- Should we validate the dosage? [YES - always validate user input]
```
