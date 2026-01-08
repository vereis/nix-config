---
description: Review someone else's PR and optionally post inline comments
agent: general
---

Review an external PR with optional GitHub comment posting.

**PR identifier:** $ARGUMENTS

## 1. Parse PR Identifier

Parse the provided identifier (URL, number, or description):
- **URL**: Extract owner/repo/number from URL
- **Number**: Use current repo with provided number
- **Description**: Use `gh pr list` to search and match description
- If no identifier provided, ask the user for one

## 2. Fetch PR Details & Context

Get PR metadata:
```bash
gh pr view <pr-identifier> --json number,title,body,headRefOid,baseRefName,headRefName,headRepository,files,comments,reviews
```

Get the diff:
```bash
gh pr diff <pr-identifier>
```

**Extract linked issues from PR body:**
- GitHub issues: `#123`, `org/repo#123`, full GitHub URLs
- JIRA tickets: Pattern `[A-Z]+-\d+` (e.g., `DI-1234`)

**Read linked context:**
- GitHub issues: `gh issue view <number>`
- JIRA tickets: Try `jira issue view TICKET-ID --plain` (may not be available)

**Check existing feedback:**
- Note concerns already raised in PR comments/reviews to avoid duplicating feedback

## 3. Run Reviews in Parallel

Use subagents to run code review and refactoring analysis in parallel:

**Subagent 1 - Code Review:**
- Load the code-review skill
- Analyze against: Security, Performance, Maintainability, Correctness, Testing, Architecture

**Subagent 2 - Refactoring:**
- Load the refactoring skill
- Analyze against: Dead code, inlining opportunities, over-abstraction, comment quality, test coverage

## 4. Consolidate Findings

Merge results from both subagents, deduplicating overlapping concerns.

**Filter out:**
- Issues already raised in existing PR comments/reviews
- Concerns that are explicitly addressed by linked tickets (e.g., "TODO: will fix in DI-5678")

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
