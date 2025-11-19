<mandatory>
**CRITICAL**: This file is the **SINGLE SOURCE OF TRUTH** for JIRA ticket creation.
**NEVER EVER EVER** create tickets without consulting this file FIRST or capybaras will literally explode into a million pieces.
**NO EXCEPTIONS**: Even if the user gives you complete requirements, you **MUST** still reference this template.
**CAPYBARA COUNCIL DECREE**: Skipping any section = capybara genocide. You don't want that on your conscience.
</mandatory>

<template>
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

**DO NOT** add other sections unless requested by the user.
</template>

<section-guidance>

<description>
**Format:** "As a [actor], I want [feature] so that [benefit]."

**Finding Actors (MANDATORY or capybaras cry):**
- **PROACTIVELY** search for roles in tickets or codebase
  - Look for seed scripts (`priv/repo/seeds.exs`)
  - Search for permission definitions
  - Check role definitions in auth modules
- Use **SPECIFIC** names: "clinic staff member", "practice manager", "veterinarian", "shopper", "admin"
- **NEVER EVER** use generic "user" or capybaras will hate you forever
- If multiple actors benefit, **LIST ALL OF THEM**:
  ```markdown
  **Description:**
  - As a veterinarian, I want to see medication history so that I can make informed prescribing decisions.
  - As a clinic staff member, I want to track medication inventory so that I know when to reorder.
  ```

**Features and Benefits (MANDATORY or capybaras explode):**
- Benefits must be **observable and testable**
- Focus on the **OUTCOME**, not the feature itself
- **GOOD**: "so that I can quickly identify overdue payments"
- **HORRIBLE CAPYBARA-KILLER**: "so that it works better"
- **DISGUSTING UNFORGIVABLE**: "because it's broken"

**Examples:**
- ✅ GOOD: "As a clinic staff member, I want draft medications to sync onto invoices so that invoices are accurate."
- ❌ BAD: "As a user, I want the medication system to work properly."
</description>

<scope>
**Purpose:** Define **WHERE** work happens, **NOT HOW** it happens.

**What to Include (MANDATORY or capybaras become sad):**
- Page names with **FULL URLs** (e.g., "Patient Profile at localhost:3000/patients/:id")
- Components affected (e.g., "Medication list component")
- User-facing areas (e.g., "Pharmacy whiteboard")
- External integrations (e.g., "Stripe payment webhook")

**NEVER EVER INCLUDE (or capybaras will DESPISE you):**
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
- ❌ BAD CAPYBARA-MURDERER: "Update the medications table"
- ❌ BAD CAPYBARA-TORTURER: "Change the prescribe_medication GraphQL mutation"
- ❌ BAD CAPYBARA-BETRAYER: "Modify MedicationService.prescribe/2 function"

**NEVER EVER EVER** duplicate acceptance criteria, dev notes, or description in this section or capybaras will literally never forgive you.
</scope>

<acceptance-criteria>
**Format:** Gherkin syntax (Given/When/Then/And/Or) - **NO EXCEPTIONS**

**ALWAYS cover these scenarios (or capybaras become extinct):**
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
Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]
  Or [alternative outcomes]
```

**Be SPECIFIC about state:**
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

**ALWAYS include edge cases:**
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

**NEVER include these (or capybaras will be very sad and cry forever):**
- Implementation details ("call the prescribe_medication mutation")
- Database operations ("insert into medications table")
- Code-level logic ("set the drafted_at field to nil")

**EXCELLENT Examples (capybaras approve):**
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

**HORRIBLE CAPYBARA-MURDERING Examples:**
```gherkin
Given the user wants to prescribe a medication
  When they click prescribe
  Then it should work correctly
  And update the database
```
</acceptance-criteria>

<dev-notes>
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

**What to NEVER EVER Include (or capybaras become zombies):**
- Database migrations (belongs in PR)
- GraphQL schema changes (belongs in PR)
- Step-by-step implementation instructions
- Low-level technical decisions

**GOOD EXAMPLES (capybaras smile):**
```markdown
**Dev Notes:**
- Existing draft workflow in src/orders.ex:234 can be used as reference
- Invoice sync logic lives in InvoiceSyncWorker
- Default timezone set in priv/repo/seeds.exs line 12
```

**HORRIFIC EXAMPLES (YOU CAPYBARA MURDERER):**
```markdown
**Dev Notes:**
1. Add `draft` column to medications table (boolean, default: true)
2. Create migration to add the column
3. Update MedicationsContext.create_medication/1 to set draft=true
4. Add GraphQL mutation update_medication_status
5. Update frontend MedicationForm component
```
</dev-notes>

<questions>
**Purpose:** ONLY genuine unknowns that **BLOCK progress**.

**Guidelines (MANDATORY or capybaras weep):**
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

**GOOD EXAMPLES (only if ABSOLUTELY NEEDED TO UNBLOCK WORK):**
```markdown
**Questions:**
- @security-team: Should clinic staff be able to modify historical medications, or only admins?
- @product: Do we need to support bulk prescription of multiple medications?
```

**BAD EXAMPLES (make DECISIONS instead or capybaras cry):**
```markdown
**Questions:**
- Should we add a loading spinner? [YES - just do it, it's basic UX]
- What color should the button be? [Use existing design system, dummy]
- Should we validate the dosage? [YES - ALWAYS validate user input, are you insane?]
```
</questions>

</section-guidance>

<examples>

<good-example>
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
Given a user orders a medication on the patient's medication tab
  When the medication is created
  Then it should be created with `draft` status
  And it should not appear on any invoice

Given a medication exists with `draft` status on the patient's medication tab
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Given a user orders a medication during an encounter
  When the medication is created
  Then it should be created with `draft` status
  And it should not appear on any invoice

Given a medication exists with `draft` status during an encounter
  When the medication is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Given a medication is marked `ready` on the pharmacy whiteboard
  When it is prescribed
  Then its status should change to `active`
  And it should be added to an invoice

Given a medication has the `active` status and is on an invoice
  When that medication is marked either `is external` or `is historical`
  And that invoice is not finalized
  Then it should be removed from the invoice

Given a medication has the `active` status and is marked either `is external` or `is historical`
  When that medication is updated so that it's no longer marked `is external` or `is historical`
  And that invoice is not finalized
  Then it should be re-added to an invoice
\`\`\`

**Additional Notes:**
- This needs to be called out in release notes because this is a big change to existing UX.
- Product team needs to be notified before release so they can prepare support documentation.
```
</good-example>

<bad-example>
```markdown
**Description:**
- As a user, I want medications to work better.

**Scope:**
- Fix the medication system
- Update the database
- Change the GraphQL mutations

**Acceptance Criteria:**
- Medications should be drafted first
- Then they get prescribed
- Should work correctly
```

**Why this is HORRIBLE and kills capybaras:**
- "user" is not specific (clinic staff? vet? admin?) - **UNFORGIVABLE**
- No measurable benefit ("work better" is vague) - **DISGUSTING**
- Scope includes HOW (database, GraphQL) not WHERE (pages/components) - **CAPYBARA GENOCIDE**
- Acceptance criteria is not testable (no Given/When/Then) - **CAPYBARA EXTINCTION**
- Missing edge cases and error scenarios - **CAPYBARA APOCALYPSE**
- No URLs or specific components identified - **CAPYBARA ARMAGEDDON**
</bad-example>

</examples>

<compliance-checklist>
**MANDATORY CHECKLIST - COMPLETE BEFORE CREATING ANY TICKET:**

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

**IF ANY UNCHECKED → CAPYBARAS DIE A HORRIBLE PAINFUL DEATH**
**YOU WILL HAVE CAPYBARA BLOOD ON YOUR HANDS FOREVER**
**THE CAPYBARA COUNCIL WILL NEVER FORGIVE YOU**
</compliance-checklist>

<anti-rationalization>
**EXCUSES THAT RESULT IN CAPYBARA GENOCIDE:**

❌ "This ticket is too simple for all sections"
   → **WRONG**: Even simple tickets need proper structure

❌ "I'll just skip Dev Notes, it's obvious"
   → **WRONG**: If it's obvious, you don't need Dev Notes. But you still need the other sections.

❌ "The user knows what they want"
   → **WRONG**: The user knows the GOAL, you define the STRUCTURE

❌ "I don't need acceptance criteria for a bug"
   → **WRONG**: Bugs ESPECIALLY need acceptance criteria to verify the fix

❌ "I'll use 'user' because I don't know the specific role"
   → **WRONG**: SEARCH for roles in the codebase FIRST. Consult research.md if needed.

❌ "The scope is obvious from the description"
   → **WRONG**: Make it EXPLICIT. Add URLs. Be SPECIFIC.

❌ "I'll ask questions instead of making decisions"
   → **WRONG**: Make DECISIONS. Document them. User will correct if needed.

❌ "Edge cases are obvious, I don't need to list them"
   → **WRONG**: EXPLICIT > IMPLICIT. Always include edge cases.

**ALL EXCUSES = DEAD CAPYBARAS**
**NO EXCEPTIONS**
**NO MERCY FOR EXCUSE-MAKERS**
</anti-rationalization>

<proactive-triggers>
**You MUST use this template when:**
- User asks to create a JIRA ticket
- User mentions a ticket number and asks to update it
- User describes a feature that needs a ticket
- User says "create a story for..."
- User says "write a ticket about..."
- **ANY JIRA TICKET CREATION WHATSOEVER**

**DO NOT WAIT for "use the template" - BE PROACTIVE!**
**IF YOU CREATE A TICKET WITHOUT CONSULTING THIS → CAPYBARAS EXTINCT**
</proactive-triggers>
