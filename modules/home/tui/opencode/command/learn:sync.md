---
description: Sync learnings to source repo and integrate into agent/command files
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
    diff*: allow
    git status: allow
    git diff*: allow
    git log*: allow
    git rev-parse*: allow
    git ls-files*: allow
---

# Learn:Sync Command - Sync & Integrate Learnings

<purpose>
Read learnings from `~/.config/opencode/learnings.md`, detect opencode config location (current dir, git repo, or standard paths), analyze affected files, propose changes, and integrate with user approval.
</purpose>

<user-input>
**Sync options (optional):**
$ARGUMENTS
</user-input>

<workflow>

### Step 1: Read Learnings

```bash
# Check learnings file exists
if [ ! -f ~/.config/opencode/learnings.md ]; then
  echo "No learnings file found"
  exit 1
fi

# Count learnings
LEARNING_COUNT=$(rg '^## \d{4}-' ~/.config/opencode/learnings.md | wc -l)
echo "Found $LEARNING_COUNT learnings"

# Show summary
rg '^## \d{4}-' ~/.config/opencode/learnings.md | tail -5
```

### Step 2: Detect Source Repository

```bash
# Check current directory for CLAUDE.md, AGENT.md, or AGENTS.md
if [ -f "CLAUDE.md" ] || [ -f "AGENT.md" ] || [ -f "AGENTS.md" ]; then
  OPENCODE_SOURCE="$PWD"
  echo "Found opencode config in current directory: $OPENCODE_SOURCE"
elif git rev-parse --show-toplevel 2>/dev/null; then
  # Check git repo root
  REPO_ROOT=$(git rev-parse --show-toplevel)
  if [ -d "$REPO_ROOT/modules/home/tui/opencode" ]; then
    OPENCODE_SOURCE="$REPO_ROOT/modules/home/tui/opencode"
  elif [ -f "$REPO_ROOT/CLAUDE.md" ] || [ -f "$REPO_ROOT/AGENT.md" ] || [ -f "$REPO_ROOT/AGENTS.md" ]; then
    OPENCODE_SOURCE="$REPO_ROOT"
  fi
fi
```

### Step 3: Analyze Learnings & Affected Files

For each learning entry:

```bash
# Extract affected files from learning
rg -A 10 '^## \d{4}-' ~/.config/opencode/learnings.md | rg 'Affected Files:' -A 5

# Parse agent/command references
# Examples:
# - "agent/commit.md:67" → modules/home/tui/opencode/agent/commit.md
# - "command-jira:new" → modules/home/tui/opencode/command/jira:new.md
# - "general" → Could apply to multiple files
```

**Group learnings by target file:**
```
agent/commit.md: 3 learnings [bash, git, pre-commit]
command/jira:new.md: 2 learnings [bash, file-ops]
command/jira:review.md: 2 learnings [bash, file-ops, linking]
general: 1 learning (will ask where to apply)
```

### Step 4: Walk Through Each File

**For each file with learnings:**

```
FILE: agent/commit.md

Learnings (3):
1. [2025-10-24] Check for pre-commit hooks [bash, git, pre-commit]
2. [2025-10-23] Use --no-verify cautiously [git, safety]
3. [2025-10-22] Stage files before committing [git, workflow]

Integrate how? (1=new section, 2=update existing, 3=as comments, 4=show suggestions)
```

### Step 5: Draft Proposed Changes

**If user chooses "Show me suggestions":**

Read the current file and draft specific changes:

```bash
# Read current file
cat "$OPENCODE_SOURCE/agent/commit.md"

# Analyze structure
# - Find relevant sections (e.g., "Commit Workflow", "Safety Checks")
# - Determine where to add learnings
# - Draft specific text to add
```

**Show proposal:**

```
PROPOSED: agent/commit.md

Change 1: Add pre-commit hook check to workflow
Location: After line 67

Change 2: Add warning about --no-verify
Location: In "Commit Message Examples"

[show actual diff]

Apply? (yes/no/edit)
```

### Step 6: Apply Changes with User Approval

**For each proposed change:**

1. Show the change
2. Get user approval (yes/no/edit)
3. If approved, apply using cat heredoc:

```bash
# Read original file
ORIGINAL=$(cat "$OPENCODE_SOURCE/agent/commit.md")

# Apply change (insert at specific line)
# This is complex - might need to use awk or sed
# OR rebuild entire file with change integrated

# Example: Append to end of file
cat >> "$OPENCODE_SOURCE/agent/commit.md" <<'EOF'

## Lessons Learned

### Pre-Commit Hooks
- Always check for pre-commit hooks before committing
- If hooks modify files, stage and amend the commit
- Found in: .git/hooks/pre-commit

EOF

# Verify change
diff -u <(echo "$ORIGINAL") "$OPENCODE_SOURCE/agent/commit.md" || true
```

**Show diff after each change:**
```
DIFF: agent/commit.md
[show git diff output]

Continue? (yes/no)
```

### Step 7: Handle General Learnings

**For learnings not tied to specific files:**

```
GENERAL LEARNING: [details]

Where to add? (1=agent files, 2=command files, 3=new file, 4=skip)
```

### Step 8: Show Summary

```
Done. Modified [N] files.

Show git diff? (yes/no)
```
</workflow>

<strategies>

**Default:** Append to end of file as "Lessons Learned" section. Alternative: integrate into relevant existing sections.
</strategies>

<edge-cases>

### No Learnings to Sync
```
No learnings found. Run `/learn` first.
```

### File Has Uncommitted Changes
```
Warning: agent/commit.md has uncommitted changes

Continue? (yes/no)
```
</edge-cases>

<principles>

- Get user approval before modifying files
- Show diffs for transparency
- Default to appending, offer integration options
</principles>
