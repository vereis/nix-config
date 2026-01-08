---
description: Review someone else's PR and optionally post inline comments
agent: build
---

Review an external PR with optional GitHub comment posting.

**PR identifier:** $ARGUMENTS

## 1. Parse PR Identifier

Parse the provided identifier (URL, number, or description):
- **URL**: Extract owner/repo/number from URL
- **Number**: Use current repo with provided number
- **Description**: Use `gh pr list` to search and match description
- If no identifier provided, ask the user for one

## 2. Fetch PR Details & Diff

Get PR metadata:
```bash
gh pr view <pr-identifier> --json number,title,body,headRefOid,baseRefName,headRefName,headRepository,files,comments,reviews
```

Get the diff:
```bash
gh pr diff <pr-identifier>
```

## 3. Use Subagents for Research (Parallel)

Use subagents to gather context in parallel - this is **research only**, not the actual review:

**Subagent 1 - Linked Issues:**
- Extract GitHub issues from PR body: `#123`, `org/repo#123`, full URLs
- Extract JIRA tickets: Pattern `[A-Z]+-\d+` (e.g., `DI-1234`)
- Fetch each: `gh issue view <number>` for GitHub, `jira issue view TICKET-ID --plain` for JIRA
- Return summaries of requirements/context from linked issues

**Subagent 2 - Existing Feedback:**
- Analyze existing PR comments and reviews
- Return list of concerns already raised (to avoid duplicating)

**Subagent 3 - Best Practices Research:**
- Based on the languages/frameworks in the diff, research relevant best practices
- Load refactoring skill for language-specific guidance (e.g., `elixir.md` for Elixir code)
- Return relevant patterns and anti-patterns to watch for

## 4. Primary Agent: Perform the Review

**The primary agent does the actual review work**, using context from subagents.

**Skip generated files** - don't review files we have little control over:
- `*.gen.ts`, `*.gen.js`, `*.generated.*`
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `*.min.js`, `*.min.css`
- Files in `node_modules/`, `vendor/`, `dist/`, `build/`
- GraphQL generated files (`*.graphql.ts`, `*_gen.go`, etc.)
- Proto generated files (`*.pb.go`, `*.pb.ex`, etc.)
- Migration files (often auto-generated or rarely worth commenting on)

Load skills:
- Load the code-review skill
- Load the refactoring skill

Analyze the diff against:
- **Code Review**: Security, Performance, Maintainability, Correctness, Testing, Architecture
- **Refactoring**: Dead code, inlining opportunities, over-abstraction, comment quality, test coverage

**Filter out:**
- Issues already raised in existing PR comments/reviews (from subagent 2)
- Concerns explicitly addressed by linked tickets (e.g., "TODO: will fix in DI-5678")

## 5. Write Comments in User's Voice

**CRITICAL: You are posting AS the user.** Comments must sound like a human colleague, not an AI.

### Comment Style Guide

**DO:**
- Be conversational and direct
- Ask questions instead of making declarations ("Why do we need X?" not "X is incorrect")
- Express genuine curiosity ("That seems like bad design to me" not "This is a design anti-pattern")
- Use "we" language ("could we add..." not "you should add...")
- Be polite but not sycophantic ("If it isn't too much trouble..." is fine)
- Suggest fixes, but prefer actually fixing over adding TODO comments
- Keep it concise - get to the point

**DON'T:**
- Use labels like `**[Warning]**` or `**[Suggestion]**` in the comment text
- Sound robotic or formal ("Type coercion inconsistency detected")
- Use jargon-heavy declarations ("Missing mutation input verification needed")
- Be condescending or lecture-y
- Over-explain - trust the reader is a competent developer

### Examples

**BAD (robotic, declarative):**
```
**[Warning]** Type coercion inconsistency detected.

You're checking for both boolean `true` AND string `"Yes"`:
[code]
This suggests `toGoHome` doesn't have a consistent type throughout the app. Fix the type definitions upstream...
```

**GOOD (conversational, questioning):**
```
Why do we need to check both `true` and `"Yes"`? That seems like bad design to me.

This suggests we don't use consistent typing throughout the app. Ideally we fix this by making sure the field is always a boolean.

**Recommendation:**
[code example]

Prefer actually fixing it rather than just adding a comment.
```

---

**BAD (demanding, accusatory):**
```
**[Warning]** Missing mutation input verification needed.

You added `toGoHome` to the mutation **response**, but I don't see it being added to the mutation **input** variables...

**Action Required:**
Verify that the mutation call includes...
```

**GOOD (curious, collaborative):**
```
You added `toGoHome` to the mutation **response**, but I don't see it being added to the mutation **input**.

Are you sure you don't need to do that? It's totally okay if this gets set elsewhere, but it wasn't clear from the code review -- you're sure the frontend actually sets this when the user toggles the checkbox?
```

---

**BAD (formal, prescriptive):**
```
**[Suggestion]** Consider adding a test for the state sync fix.

The core bug was state synchronization between panels. While the fix looks correct, there's no test ensuring...

**Recommendation:**
Add a unit test for `usePrescriptionState`...
```

**GOOD (friendly request):**
```
While the fix seems correct, there are no tests to ensure this actually works.

If it isn't too much trouble, could we add a unit test for `usePrescriptionState` that verifies that when the `prescription` prop changes, `editedValues.toGoHome` updates accordingly.

This prevents regressions from happening in the future.
```

## 6. Present Findings for Approval

Show high-level summary first:
```
PR Review Summary for #123: "Add user authentication"
- 5 files changed (+234, -12 lines)
- Linked: DI-1234 (User auth epic), #99 (Security requirements)
- Found 3 new issues: 1 critical, 1 warning, 1 suggestion
- Filtered 2 issues already raised by @reviewer
```

Then show each proposed comment with code excerpt (use severity internally for ordering, but don't include labels in the actual comment):
```
1. src/auth.js:42 (Critical)
   Code:
   > const query = "SELECT * FROM users WHERE id = " + userId;
   
   Comment:
   "This looks like it could be vulnerable to SQL injection. Could we use parameterized queries instead?
   
   Something like:
   const query = "SELECT * FROM users WHERE id = ?";
   db.query(query, [userId]);"

2. utils.py:15 (Warning)
   Code:
   > def process_data(items):
   >     return [expensive_operation(x) for x in items]
   
   Comment:
   "This processes all items in memory at once. For large datasets, that could be a problem.
   
   Would it make sense to use a generator or batch processing here?"

Approve posting these comments? (yes/no/select)
```

## 6. Wait for Explicit Approval

**NEVER post comments without explicit approval.**

Options:
- `yes` - Post all comments
- `no` - Cancel
- `select` - Let user pick which comments to post

## 7. Post Approved Comments

If approved, post comments using:
```bash
gh api repos/OWNER/REPO/pulls/NUMBER/comments \
  -f body="COMMENT_TEXT" \
  -f commit_id="HEAD_COMMIT_SHA" \
  -f path="FILE_PATH" \
  -F line=LINE_NUMBER \
  -f side="RIGHT"
```

For multi-line comments, add `-F start_line=X -f start_side="RIGHT"`

**Important:**
- Only use commits that exist in the PR (use headRefOid from step 2)
- Show confirmation of posted comments with links
