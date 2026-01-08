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

## 5. Present Findings for Approval

Show high-level summary first:
```
PR Review Summary for #123: "Add user authentication"
- 5 files changed (+234, -12 lines)
- Linked: DI-1234 (User auth epic), #99 (Security requirements)
- Found 3 new issues: 1 critical, 1 warning, 1 suggestion
- Filtered 2 issues already raised by @reviewer
```

Then show each proposed comment with code excerpt:
```
1. [Critical] src/auth.js:42
   Code:
   > const query = "SELECT * FROM users WHERE id = " + userId;
   
   Comment:
   "Potential SQL injection vulnerability. Use parameterized queries instead:
   const query = "SELECT * FROM users WHERE id = ?";
   db.query(query, [userId]);"

2. [Warning] utils.py:15
   Code:
   > def process_data(items):
   >     return [expensive_operation(x) for x in items]
   
   Comment:
   "This function processes all items in memory. For large datasets, consider 
   using a generator or batch processing to reduce memory footprint."

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
