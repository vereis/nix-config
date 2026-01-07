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

6. Present ALL proposed comments to user for approval:
   ```
   Found 3 issues to comment on:
   
   1. [Critical] file.js:42
      "Potential SQL injection vulnerability..."
   
   2. [Warning] utils.py:15
      "This function could benefit from..."
   
   3. [Suggestion] README.md:10
      "Consider adding..."
   
   Approve posting these comments? (yes/no)
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
- Show the full comment text in the preview
- Only use commits that exist in the PR (use headRefOid from step 2)
- For multi-line comments, add `-F start_line=X -f start_side="RIGHT"`
