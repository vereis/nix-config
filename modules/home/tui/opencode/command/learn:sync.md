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

## Purpose

1. Read learnings from `~/.config/opencode/learnings.md`
2. Detect source repository (nix-config, dotfiles, etc.)
3. Analyze which agent/command files each learning affects
4. Propose changes to integrate learnings into source files
5. Walk through each change with user approval
6. Apply approved changes
7. Copy learnings.md to source repo

This ensures learnings don't just sit in a file - they get integrated back into the prompts!

## User Input
**Sync options (optional):**
$ARGUMENTS

## Workflow

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
# Strategy 1: Check if we're IN a repo with opencode config
if git rev-parse --show-toplevel 2>/dev/null; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
  if [ -d "$REPO_ROOT/modules/home/tui/opencode" ]; then
    OPENCODE_SOURCE="$REPO_ROOT/modules/home/tui/opencode"
    echo "✅ Found opencode source at: $OPENCODE_SOURCE"
  fi
fi

# Strategy 2: Search common locations
if [ -z "$OPENCODE_SOURCE" ]; then
  for path in \
    ~/nix-config/modules/home/tui/opencode \
    ~/.config/nixos/modules/home/tui/opencode \
    ~/.dotfiles/opencode \
    ~/dotfiles/opencode; do
    if [ -d "$path" ]; then
      OPENCODE_SOURCE="$path"
      echo "✅ Found opencode source at: $OPENCODE_SOURCE"
      break
    fi
  done
fi

# Strategy 3: Ask user
if [ -z "$OPENCODE_SOURCE" ]; then
  echo "❓ Could not auto-detect opencode source location"
fi
```

**If not found, ask user:**
```
❓ Where is your opencode source configuration?

I checked these locations:
- Current git repo: [result]
- ~/nix-config/modules/home/tui/opencode
- ~/.config/nixos/modules/home/tui/opencode
- ~/.dotfiles/opencode

Options:
1. **Specify path** - Tell me where it is
2. **Skip integration** - Just show learnings, don't integrate
3. **Cancel** - Do nothing

Your choice? (1/2/3)
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
📋 Learning Analysis:

agent/commit.md:
  - 3 learnings to integrate
  - Tags: [bash, git, pre-commit]

command/jira:new.md:
  - 2 learnings to integrate
  - Tags: [bash, file-ops]

command/jira:review.md:
  - 2 learnings to integrate
  - Tags: [bash, file-ops, linking]

general (no specific file):
  - 1 learning (will ask where to apply)
```

### Step 4: Walk Through Each File

**For each file with learnings:**

```
═══════════════════════════════════
FILE: agent/commit.md
═══════════════════════════════════

📚 Learnings to integrate (3):

1. [2025-10-24] Check for pre-commit hooks
   Tags: [bash, git, pre-commit]
   
2. [2025-10-23] Use --no-verify cautiously
   Tags: [git, safety]
   
3. [2025-10-22] Stage files before committing
   Tags: [git, workflow]

═══════════════════════════════════

How should I integrate these?

1. **Add new section** - Create "Lessons Learned" or "Common Pitfalls" section
2. **Update existing sections** - Integrate into relevant sections
3. **Add as comments** - Append as inline comments/notes
4. **Show me suggestions** - Let me draft specific changes first

Your choice? (1/2/3/4)
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
═══════════════════════════════════
PROPOSED CHANGES: agent/commit.md
═══════════════════════════════════

📝 Change 1: Add pre-commit hook check to workflow

Location: After line 67 (in "Data Gathering Protocol" section)

ADD:
```markdown
### 3. Check for Pre-Commit Hooks

\```bash
# Check if pre-commit hooks exist
if [ -x .git/hooks/pre-commit ]; then
  echo "⚠️  Pre-commit hooks detected - may modify files"
fi
\```

**Important:** If pre-commit hooks modify files, you MUST:
1. Let initial commit complete
2. Check git status for modified files
3. Stage and amend commit if files were changed
```

─────────────────────────────────────

📝 Change 2: Add warning about --no-verify

Location: In "Commit Message Examples" section, add warning

ADD:
```markdown
### ⚠️ Using --no-verify

AVOID using `git commit --no-verify` unless absolutely necessary!
- Bypasses pre-commit hooks
- Bypasses commit-msg hooks
- May result in incomplete commits
- Only use when hooks are genuinely blocking valid commits
```

─────────────────────────────────────

Apply these changes? (yes/no/edit)
- **yes** - Apply all changes
- **no** - Skip this file
- **edit** - Let me modify specific changes
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
═══════════════════════════════════
DIFF: agent/commit.md
═══════════════════════════════════

[Show git diff output highlighting changes]

═══════════════════════════════════

Change applied! Continue to next change? (yes/no)
```

### Step 7: Handle General Learnings

**For learnings not tied to specific files:**

```
═══════════════════════════════════
GENERAL LEARNING (no specific file)
═══════════════════════════════════

Learning: [Show learning details]

This learning doesn't specify which file(s) to update.

Where should this be added?

1. **Agent files** - Which agent(s)? (e.g., commit, pr, task)
2. **Command files** - Which command(s)? (e.g., jira:new, jira:review)
3. **New file** - Create a new file (e.g., LEARNINGS.md in opencode/)
4. **Skip** - Don't integrate this one

Your choice? (1/2/3/4)
```

### Step 8: Copy Learnings File to Source

```bash
# Copy learnings.md to source repo
cp ~/.config/opencode/learnings.md "$OPENCODE_SOURCE/learnings.md"

# Show diff if file already exists
if git diff "$OPENCODE_SOURCE/learnings.md" 2>/dev/null; then
  echo "Updated learnings.md with new entries"
else
  echo "Created learnings.md"
fi
```

### Step 9: Show Summary & Next Steps

```
═══════════════════════════════════
SYNC COMPLETE
═══════════════════════════════════

✅ Changes Applied:

Files modified:
  - agent/commit.md (3 changes)
  - command/jira:new.md (2 changes)
  - command/jira:review.md (2 changes)
  - learnings.md (copied)

📊 Summary:
  - Total learnings synced: 7
  - Files updated: 4
  - Lines added: ~50

═══════════════════════════════════

📋 Next Steps (NixOS users):

1. Review changes:
   cd $OPENCODE_SOURCE
   git diff

2. Run formatter:
   nix fmt

3. Commit changes:
   git add -A
   git commit -m "[CHORE] Integrate learnings from conversations"

4. Apply changes:
   home-manager switch

5. Verify in new conversation:
   opencode
   # Start conversation and see if learnings are applied

═══════════════════════════════════

📋 Next Steps (non-NixOS users):

1. Review changes:
   cd ~/.config/opencode
   
2. Changes are already active!
   # Just start a new conversation

═══════════════════════════════════

Would you like me to show the git diff? (yes/no)
```

## Integration Strategies

### Strategy 1: Append to End
- Safest, least invasive
- Add "Lessons Learned" section at end of file
- Works for any file structure

### Strategy 2: Insert in Relevant Section
- More sophisticated
- Requires parsing file structure
- Finds best location based on learning content
- Example: Pre-commit learning → insert in "Workflow" section

### Strategy 3: Update Existing Content
- Most advanced
- Modify existing instructions based on learnings
- Example: Change "optional" to "required" based on learning
- Requires careful analysis and user approval

**Recommend Strategy 1 initially, offer Strategy 2 for experienced users**

## Edge Cases

### No Learnings to Sync
```
📭 No learnings found in ~/.config/opencode/learnings.md

Nothing to sync!

Use `/learn` to capture learnings first, then `/learn:sync` to integrate them.
```

### Learnings Already Integrated
```
🔍 Checking which learnings are already integrated...

Found that 5/7 learnings are already present in source files.

Only 2 new learnings to integrate:
  - [2025-10-24] agent-commit: Pre-commit hook handling
  - [2025-10-24] command-jira:new: File writing improvements

Continue with just these 2? (yes/no)
```

### Conflicts with Existing Content
```
⚠️ Warning: Learning conflicts with existing instructions

Learning says: "Never use --no-verify"
But agent/commit.md line 45 says: "Use --no-verify when hooks fail"

How to resolve?

1. **Keep existing** - Skip this learning
2. **Replace** - Use learning, remove old instruction
3. **Merge** - Combine both (I'll draft suggestion)
4. **Manual** - I'll flag for manual review

Your choice? (1/2/3/4)
```

### File Has Uncommitted Changes
```
⚠️ Warning: agent/commit.md has uncommitted changes

I can still integrate learnings, but:
- May create merge conflicts
- Harder to review what changed
- Risk of losing your uncommitted work

Options:

1. **Continue anyway** - I'll be careful
2. **Commit first** - Go commit your changes, then re-run
3. **Cancel** - Don't sync now

Your choice? (1/2/3)
```

### Dry Run Mode
```
$ARGUMENTS = "dry-run" or "--dry-run"

Run in dry-run mode:
- Show all proposed changes
- Don't actually modify any files
- Let user review before real sync
```

## File Location Detection

### NixOS / home-manager
```
modules/home/tui/opencode/
├── agent/
├── command/
├── learnings.md (synced here)
├── AGENTS.md
└── opencode.json
```

### Standard dotfiles
```
~/.dotfiles/opencode/
├── agent/
├── command/
├── learnings.md
└── config.json
```

### Direct ~/.config
```
~/.config/opencode/
├── agent/
├── command/
└── learnings.md (already here!)
```

## Key Principles

1. **User Approval Required** - Never modify files without showing changes first
2. **Show Diffs** - Always show before/after for transparency
3. **Graceful Degradation** - If can't auto-integrate, suggest manual approach
4. **Preserve Intent** - Don't just copy learnings, integrate them meaningfully
5. **Safe Defaults** - Start with append strategy, offer advanced options
6. **Detect Conflicts** - Check for contradictions with existing content
7. **Version Control Friendly** - Encourage review via git diff
8. **Minimal Output** - Return only final summaries to primary agent, not internal analysis or file reads (user sees subagent output directly)

## Advanced Features (Future)

- **Auto-detect best integration point** using semantic analysis
- **Merge similar learnings** to avoid duplication
- **Learning priority** - some learnings override others
- **Expiry dates** - mark learnings as "applied" after integration
- **Learning templates** - suggest where new learnings should go based on patterns
