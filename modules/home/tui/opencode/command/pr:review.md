---
description: Review someone else's PR and optionally post inline comments
agent: build
---

Review an external PR with optional GitHub comment posting:

1. Parse PR identifier (URL, number, or description like "vereis' pr for XYZ"):
   - **URL**: Extract owner/repo/number from URL
   - **Number**: Use current repo with provided number
   - **Description**: Use `gh pr list` to search and match description
   
2. Fetch PR details:
   ```bash
   gh pr view <pr-identifier> --json number,title,body,headRefOid,baseRefName,headRefName,headRepository,files
   ```

3. Get the diff for review:
   ```bash
   gh pr diff <pr-identifier>
   ```

4. Load the code-review skill and analyze all changes:
   - Security
   - Performance
   - Maintainability
   - Correctness
   - Testing
   - Architecture

5. For each issue found, prepare an inline comment with:
   - File path
   - Line number
   - Severity (Critical/Warning/Suggestion)
   - Description and fix recommendation

6. Present ALL proposed comments to user for approval with context:
   
   Show high-level summary first:
   ```
   PR Review Summary for #123: "Add user authentication"
   - 5 files changed (+234, -12 lines)
   - Found 3 issues: 1 critical, 1 warning, 1 suggestion
   ```
   
   Then show each comment with code excerpt:
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
   
   3. [Suggestion] README.md:10
      Code:
      > ## Installation
      > Run npm install
      
      Comment:
      "Consider adding version requirements: Node.js 18+ required."
   
   Approve posting these 3 comments? (yes/no)
   ```

7. **WAIT for explicit user approval** before posting

8. If approved, post comments using:
   ```bash
   gh api repos/OWNER/REPO/pulls/NUMBER/comments \
     -f body="COMMENT_TEXT" \
     -f commit_id="HEAD_COMMIT_SHA" \
     -f path="FILE_PATH" \
     -F line=LINE_NUMBER \
     -f side="RIGHT"
   ```

**Important:**
- NEVER post comments without explicit approval
- Show high-level PR context (title, file count, line changes)
- Include minimal code excerpts (1-3 lines) for each comment
- Show the full comment text that will be posted
- Only use commits that exist in the PR (use headRefOid from step 2)
- For multi-line comments, add `-F start_line=X -f start_side="RIGHT"`
