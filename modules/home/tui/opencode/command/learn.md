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
---

# Learn Command - Capture Conversation Learnings

## Purpose

Analyze the current conversation for corrections, mistakes, and learnings, then save them to `~/.config/opencode/learnings.md` for future reference and integration.

## User Input
**What to learn from this conversation:**
$ARGUMENTS

## Workflow

### Step 1: Analyze Conversation

Review the current conversation history for:
- **Corrections** - Where user corrected the LLM's approach
- **Mistakes** - Where the LLM made errors or wrong assumptions
- **Best Practices** - Patterns that worked well
- **Edge Cases** - Unexpected situations encountered
- **Command Failures** - Bash commands that failed and why
- **Workflow Improvements** - Better ways to approach tasks

**Look for patterns like:**
- "Actually, that's wrong..."
- "No, you should do X instead..."
- "The command failed because..."
- "Don't do X, do Y instead..."
- "Remember to always..."

### Step 2: Extract Key Learnings

For each learning, capture:
1. **Context** - What was being attempted
2. **Issue** - What went wrong or what was corrected
3. **Fix** - The correct approach
4. **Why** - Explanation of why this matters
5. **Affected Files** - Which agents/commands this applies to (if specific)
6. **Tags** - Labels for categorization (e.g., [bash, error-handling, workflow])

### Step 3: Draft Learning Entry

Format each learning as:

```markdown
## YYYY-MM-DD | <agent-name> or <command-name> or general | Tags: [tag1, tag2]

**Context:** <What was being attempted>

**Issue:** <What went wrong or what was corrected>

**Fix:** <The correct approach>

**Why:** <Explanation of why this matters>

**Affected Files:** <List specific files if applicable, e.g., agent/commit.md:42>

---
```

### Step 4: Show Draft to User

Present all extracted learnings:

```
═══════════════════════════════════
LEARNINGS EXTRACTED
═══════════════════════════════════

I found [N] learnings from this conversation:

[Show each learning entry formatted as above]

═══════════════════════════════════

What would you like to do?
1. **Approve all** - Save all learnings as-is
2. **Edit** - Let me know which to modify/remove
3. **Cancel** - Don't save anything

Your choice? (1/2/3)
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
# Check if learnings file exists
if [ -f ~/.config/opencode/learnings.md ]; then
  echo "Learnings file exists, will append"
else
  echo "Creating new learnings file"
fi

# Append learnings to file
cat >> ~/.config/opencode/learnings.md <<'EOF'

[Learning entries go here]
EOF

# Verify it was written
tail -20 ~/.config/opencode/learnings.md
```

### Step 7: Confirm Success

```
✅ Learnings saved to ~/.config/opencode/learnings.md

📊 Summary:
- Added [N] learning entries
- Tags: [list unique tags]
- Affected: [list affected agents/commands]

📋 Next Steps:
- Use `/learn:read` to view all learnings
- Use `/learn:sync` to integrate learnings into source files
- Run `home-manager switch` if using NixOS (after sync)

💡 Tip: These learnings will help improve future interactions!
```

## Edge Cases

### No Learnings Found
```
🤔 I didn't find any obvious corrections or learnings in this conversation.

The conversation seems to have gone smoothly, or learnings might be too subtle.

Would you like to:
1. **Manually specify** what to learn (tell me what you want captured)
2. **Cancel** - nothing to save

Your choice? (1/2)
```

### User Provides Manual Learning
If user specifies what to learn in $ARGUMENTS:
- Skip automatic analysis
- Use their input to create learning entry
- Still show draft for approval
- Example: `/learn Remember to always check for pre-commit hooks before committing`

### Learnings File Already Has Similar Entry
- Check for duplicate/similar learnings (by tags/content)
- Warn user: "Found similar learning from YYYY-MM-DD, should I merge or add separately?"

## Learning Categories & Tags

**Common Tags:**
- `[bash]` - Bash command issues
- `[error-handling]` - Error handling patterns
- `[workflow]` - Process improvements
- `[file-ops]` - File operations
- `[git]` - Git-related learnings
- `[permissions]` - Permission issues
- `[nix]` - NixOS-specific learnings
- `[jira]` - JIRA workflow learnings
- `[prompting]` - LLM prompting improvements
- `[edge-case]` - Edge case handling

**Agent-Specific Tags:**
- `[agent-commit]`
- `[agent-pr]`
- `[agent-task]`
- `[agent-test]`
- `[command-jira]`

## Example Learning Entry

```markdown
## 2025-10-24 | command-jira:new | Tags: [bash, file-ops, error-handling]

**Context:** JIRA command instructions included `rm -f /tmp/jira_ticket_description.md` before writing with cat heredoc

**Issue:** The rm command failed with permission errors when working directory restrictions were active

**Fix:** Remove `rm -f` commands entirely - `cat > file` always overwrites the file and creates it if it doesn't exist

**Why:** Simpler, fewer commands, avoids permission issues, more reliable

**Affected Files:** 
- command/jira:new.md:167
- command/jira:review.md:433

---
```

## Key Principles

1. **Be Specific** - Capture exact file locations and line numbers
2. **Explain Why** - Don't just say what to do, explain why it matters
3. **Tag Appropriately** - Use consistent tags for easy searching
4. **User Approval Required** - Never save without showing user first
5. **Preserve Context** - Include enough context to understand the learning later
6. **Actionable** - Learnings should be concrete enough to apply
7. **Keep It Minimal** - Learning entries must be concise to avoid context pollution when read back later

## Integration with Other Commands

- `/learn:read` - Read learnings back into conversation context
- `/learn:sync` - Sync learnings to source repo and integrate into agent files
