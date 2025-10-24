---
description: Capture learnings from conversation corrections and mistakes
mode: subagent
tools:
  write: false
  edit: false
permission:
  bash:
    ls*: allow
    cat*: allow
    grep*: allow
    rg*: allow
    find*: allow
    head*: allow
    tail*: allow
    tree*: allow
    echo*: allow
    date*: allow
    wc*: allow
    git remote*: allow
---

# Learn Command - Capture Conversation Learnings

<purpose>
Analyze the current conversation for corrections, mistakes, and learnings, then save them to `~/.config/opencode/learnings.md` for future reference and integration.
</purpose>

<user-input>
**What to learn from this conversation:**
$ARGUMENTS
</user-input>

<workflow>

### Step 1: Analyze Conversation

Review the current conversation history for:
- **Corrections** - Where user corrected the LLM's approach
- **Mistakes** - Where the LLM made errors or wrong assumptions
- **Best Practices** - Patterns that worked well
- **Edge Cases** - Unexpected situations encountered
- **Command Failures** - Bash commands that failed and why
- **Workflow Improvements** - Better ways to approach tasks

Look for: corrections, "do X instead", command failures, workflow improvements.

### Step 2: Extract Key Learnings

For each learning, capture:
1. **Context** - What was being attempted
2. **Issue** - What went wrong or what was corrected
3. **Fix** - The correct approach
4. **Why** - Explanation of why this matters
5. **Example** - Code example if available and helpful (optional)
6. **Affected Files** - Which agents/commands this applies to (if specific)
7. **Tags** - Labels for categorization (e.g., [bash, error-handling, workflow])

### Step 3: Draft Learning Entry

Format each learning as:

```markdown
## YYYY-MM-DD | <agent-name> or <command-name> or general | Tags: [tag1, tag2]

**Context:** <What was being attempted>

**Issue:** <What went wrong or what was corrected>

**Fix:** <The correct approach>

**Why:** <Explanation of why this matters>

**Example:** (optional, only if good example exists)
```language
<code example>
```

**Affected Files:** <List specific files if applicable, e.g., agent/commit.md:42>

---
```

### Step 4: Show Draft to User

Present extracted learnings:

```
Found [N] learnings:

[Show each learning entry formatted as above]

Approve? (1=yes, 2=edit, 3=cancel)
```

### Step 5: Get User Approval & Edits

**If user chooses "Edit":**
- Ask which learning to modify/remove
- Show updated draft
- Get approval again

**If user chooses "Approve":**
- Proceed to save

**If user chooses "Cancel":**
- Exit without saving

### Step 6: Save to Learnings File

```bash
# Append learnings
cat >> ~/.config/opencode/learnings.md <<'EOF'

[Learning entries go here]
EOF

# Verify
tail -20 ~/.config/opencode/learnings.md
```

### Step 7: Confirm Success

```
Saved to ~/.config/opencode/learnings.md
```
</workflow>

<edge-cases>

### No Learnings Found
```
No corrections or learnings found.

Options:
1. Manually specify what to learn
2. Cancel

Choice? (1/2)
```

### User Provides Manual Learning
If user specifies what to learn in $ARGUMENTS:
- Skip automatic analysis
- Use their input to create learning entry
- Still show draft for approval
- Example: `/learn Remember to always check for pre-commit hooks before committing`
</edge-cases>

<tags>

**Common:** `[bash]`, `[error-handling]`, `[workflow]`, `[file-ops]`, `[git]`, `[permissions]`, `[nix]`, `[jira]`, `[prompting]`, `[edge-case]`

**Agent-Specific:** `[agent-commit]`, `[agent-pr]`, `[agent-task]`, `[agent-test]`, `[command-jira]`
</tags>

<example>

```markdown
## 2025-10-24 | command-jira:new | Tags: [bash, file-ops, error-handling]

**Context:** JIRA command instructions included `rm -f /tmp/jira_ticket_description.md` before writing with cat heredoc

**Issue:** The rm command failed with permission errors when working directory restrictions were active

**Fix:** Remove `rm -f` commands entirely - `cat > file` always overwrites the file and creates it if it doesn't exist

**Why:** Simpler, fewer commands, avoids permission issues, more reliable

**Example:**
```bash
# Bad
rm -f /tmp/file.md
cat > /tmp/file.md <<'EOF'
content
EOF

# Good
cat > /tmp/file.md <<'EOF'
content
EOF
```

**Affected Files:**
- command/jira:new.md:167
- command/jira:review.md:433

---
```
</example>

<principles>

- Be specific: file locations with line numbers
- Explain why, not just what
- Tag consistently for easy searching
- Never save without user approval
- Preserve context for later understanding
- Keep entries concise and actionable
</principles>

<integration>
- `/learn:read` - Read learnings back into conversation context
- `/learn:sync` - Sync learnings to source repo and integrate into agent files
</integration>
