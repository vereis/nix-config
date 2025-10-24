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

<purpose>
Read learnings from `~/.config/opencode/learnings.md` and display them in the conversation so the LLM can reference them for future decisions.
</purpose>

<user-input>
**Filter criteria (optional):**
$ARGUMENTS
</user-input>

<workflow>

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
[Display learnings content]

Summary: [N] total, tags: [list], range: [earliest]-[latest]
```

### Step 5: Suggest Relevant Learnings

Based on conversation context, highlight relevant learnings (e.g., `[agent-commit]` if discussing commits, `[bash]` if seeing errors).
</workflow>

<examples>

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

### Show Statistics or Recent
```
/learn:read stats
/learn:read recent
/learn:read last 5
```
</examples>

<edge-cases>

### No Learnings File
```
No learnings file at ~/.config/opencode/learnings.md

Run `/learn` first to capture learnings.
```

### No Matching Learnings
```
No learnings matching: <filter>

Available: [tags], [agents]
Try: `/learn:read` or `/learn:read stats`
```

### Malformed Learnings File
```
Warning: Formatting issues in learnings file

Options: 1=show raw, 2=parse anyway, 3=cancel
Choice? (1/2/3)
```
</edge-cases>

<formatting>

**Compact (default):** Show header + fix only
**Detailed (<5 results):** Show full entry with context, issue, fix, why, affected files

**Statistics View:** Show total count, learnings per tag/agent, date range. Use `rg` and `wc -l` for counting.
</formatting>

<principles>

- Make learnings actionable - suggest how to apply
- Context-aware - highlight relevant to current conversation
- Support multiple filter types
- Adjust detail level based on result count
</principles>

<integration>
- Used by `/learn:sync` to read learnings before integrating
- LLM can reference these learnings in current conversation
- User can review learnings before deciding to sync
</integration>
