# JIRA Ticket Template

## Standard Structure

```markdown
**Description:**
  - As a [specific actor/role], I want [feature] so that [measurable benefit].
  - As a [actor2], I want [feature2] so that [benefit2].
  ...

**Scope:**
  - [High level user-facing pages/components affected, with URLs if applicable e.g. Aged AR Report at localhost:3000/financials/aged_accounts_receivable/]
  - [Call out anything NOT in scope if helpful e.g. **Out of Scope:** changes to underlying ledger entries]
  ...

**Dev Notes:** (Optional - high-level pointers only)
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

**Acceptance Criteria:**
\`\`\`gherkin
# Happy Path
Given [initial system state/context]
  When [user action or event occurs]
  Or [alternative action]
  Then [expected outcome]
  And [additional observable results]
  Or [alternative outcomes]

# Edge Cases (Always include!)
Given [edge condition: empty state, null values, max limits]
  When [action]
  Then [graceful handling]

# Error Scenarios
Given [error condition: invalid input, permissions]
  When [triggering action]
  Then [appropriate error handling and user feedback]
\`\`\`
```

**DO NOT** add other sections unless requested by the user.

## GOOD Example

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

## BAD Example

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

**Why this is bad:**
- "user" is not specific (clinic staff? vet? admin?)
- No measurable benefit ("work better" is vague)
- Scope includes HOW (database, GraphQL) not WHERE (pages/components)
- Acceptance criteria is not testable (no Given/When/Then)
- Missing edge cases and error scenarios
- No URLs or specific components identified
