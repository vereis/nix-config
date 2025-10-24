---
description: Read and display learnings from previous conversations
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
    wc*: allow
---

# Learn:Read Command - Display Captured Learnings

## Purpose

Read learnings from `~/.config/opencode/learnings.md` and display them in the conversation so the LLM can reference them for future decisions.

## User Input
**Filter criteria (optional):**
$ARGUMENTS

## Workflow

### Step 1: Check Learnings File Exists

```bash
if [ -f ~/.config/opencode/learnings.md ]; then
  cat ~/.config/opencode/learnings.md
else
  echo "No learnings file found"
fi
```

### Step 2: Parse Filter Criteria

**If user provides filter in $ARGUMENTS:**
- Filter by tags: `/learn:read bash` or `/learn:read [bash, git]`
- Filter by agent: `/learn:read agent-commit`
- Filter by date: `/learn:read 2025-10`
- Filter by keyword: `/learn:read "permission error"`

**If no filter provided:**
- Show all learnings

### Step 3: Apply Filters

```bash
# Example: Filter by tag
rg '\[bash\]' ~/.config/opencode/learnings.md -A 15

# Example: Filter by agent
rg 'agent-commit' ~/.config/opencode/learnings.md -A 15

# Example: Filter by date range
rg '^## 2025-10' ~/.config/opencode/learnings.md -A 15

# Example: Show last N entries
tail -100 ~/.config/opencode/learnings.md

# Example: Count learnings by tag
rg '\[.*\]' ~/.config/opencode/learnings.md -o | sort | uniq -c
```

### Step 4: Format and Display

```
═══════════════════════════════════
CAPTURED LEARNINGS
═══════════════════════════════════

[If filtered]
Filter: <filter criteria>
Found [N] matching learnings

[If showing all]
Showing all [N] learnings

═══════════════════════════════════

[Display learnings here, formatted nicely]

═══════════════════════════════════

📊 Summary:
- Total learnings: [N]
- Unique tags: [list tags with counts]
- Date range: [earliest] to [latest]
- Most affected: [top 3 agents/commands]

💡 Use these learnings to improve current task!
```

### Step 5: Suggest Relevant Learnings

**Based on current conversation context:**
- If talking about git commits → highlight `[agent-commit]` learnings
- If talking about JIRA → highlight `[command-jira]` learnings
- If seeing bash errors → highlight `[bash, error-handling]` learnings

```
🔍 Relevant to current conversation:

[Show 2-3 most relevant learnings based on context]

Want to see more? Use filters:
- `/learn:read agent-commit` - All commit-related learnings
- `/learn:read [bash]` - All bash-related learnings
```

## Filter Examples

### By Tag
```
/learn:read bash
/learn:read [error-handling]
/learn:read [bash, git]
```

### By Agent/Command
```
/learn:read agent-commit
/learn:read command-jira:new
/learn:read general
```

### By Date
```
/learn:read 2025-10
/learn:read 2025-10-24
```

### By Keyword
```
/learn:read "permission"
/learn:read "rm -f"
/learn:read "pre-commit"
```

### Show Statistics
```
/learn:read stats
```
Shows:
- Total learnings count
- Learnings per tag (sorted)
- Learnings per agent (sorted)
- Learnings per month
- Most common issues

### Show Recent
```
/learn:read recent
/learn:read last 5
```

## Edge Cases

### No Learnings File
```
📭 No learnings file found at ~/.config/opencode/learnings.md

This is normal if you haven't used `/learn` yet!

To create your first learning:
1. Have a conversation with corrections/improvements
2. Run `/learn` to capture those learnings
3. Run `/learn:read` to see them

Want to start now? Just run `/learn` in your next conversation!
```

### No Matching Learnings
```
🔍 No learnings found matching: <filter>

Available tags: [list all tags]
Available agents: [list all agents with learnings]

Try:
- `/learn:read` - Show all learnings
- `/learn:read stats` - See what's available
```

### Malformed Learnings File
```
⚠️ Warning: Learnings file exists but has formatting issues

I can still try to read it, but some entries might not parse correctly.

Would you like me to:
1. **Show raw content** - Display file as-is
2. **Try to parse** - Attempt to extract learnings anyway
3. **Cancel** - Don't read

Your choice? (1/2/3)
```

## Display Formatting

**Compact View (default):**
```
## 2025-10-24 | agent-commit | Tags: [bash, git]
Fix: Always check for pre-commit hooks before committing
---
```

**Detailed View (when filtered to <5 results):**
```
## 2025-10-24 | agent-commit | Tags: [bash, git]

**Context:** Creating git commits without checking for pre-commit hooks
**Issue:** Pre-commit hooks modified files after commit, requiring amend
**Fix:** Always check for pre-commit hooks and re-commit if files modified
**Why:** Ensures all automated changes are included in commit
**Affected Files:** agent/commit.md:67

---
```

## Statistics View

```bash
# Count total learnings
rg '^## \d{4}-' ~/.config/opencode/learnings.md | wc -l

# Count by tag
rg '\[([^]]+)\]' ~/.config/opencode/learnings.md -o --no-filename | sort | uniq -c | sort -rn

# Count by agent
rg '^## \d{4}-\d{2}-\d{2} \| ([^|]+)' ~/.config/opencode/learnings.md -o --no-filename | cut -d'|' -f2 | sort | uniq -c | sort -rn

# Show date range
rg '^## (\d{4}-\d{2}-\d{2})' ~/.config/opencode/learnings.md -o --no-filename | sort | uniq | head -1
rg '^## (\d{4}-\d{2}-\d{2})' ~/.config/opencode/learnings.md -o --no-filename | sort | uniq | tail -1
```

## Key Principles

1. **Make Learnings Actionable** - Don't just display, suggest how to apply
2. **Context-Aware** - Highlight relevant learnings for current conversation
3. **Easy Filtering** - Support multiple filter types for quick access
4. **Statistics** - Help user understand what learnings exist
5. **Formatting** - Adjust detail level based on number of results
6. **Minimal Output** - Return only final summaries to primary agent, not internal analysis or file reads (user sees subagent output directly)

## Integration

- Used by `/learn:sync` to read learnings before integrating
- LLM can reference these learnings in current conversation
- User can review learnings before deciding to sync
