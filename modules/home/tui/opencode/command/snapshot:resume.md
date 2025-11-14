---
description: Resume work from a previously created task snapshot
mode: agent
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
    git status: allow
    git diff*: allow
    git log*: allow
    git show*: allow
    git branch*: allow
    git grep*: allow
    git ls-files*: allow
    git ls-tree*: allow
    git rev-parse*: allow
    git describe*: allow
    git tag: allow
    git remote*: allow
    git config --get*: allow
    git config --list: allow
    jira issue view*: allow
    gh issue view*: allow
---

# Task Snapshot Resume

<purpose>
Load a previously created task snapshot and resume work. Restores context, decisions, and todo list so you can pick up exactly where you left off.
</purpose>

<arguments>
$ARGUMENTS = snapshot name (without path or extension)

Examples:
- `/snapshot:resume my-task` → loads ~/.config/opencode/snapshots/my-task.md
- `/snapshot:resume skills-migration` → loads ~/.config/opencode/snapshots/skills-migration.md
</arguments>

<workflow>

### Step 1: Locate Snapshot File

**Search order:**
1. `$HOME/.config/opencode/snapshots/[name].md`
2. `$HOME/.config/opencode/snapshots/[name]` (if .md missing)
3. `/tmp/[name].md`
4. `/tmp/[name]`

**Handle errors:**
```bash
# If file not found
echo "❌ Snapshot not found: [name]"
echo ""
echo "Available snapshots:"
ls -1 "$HOME/.config/opencode/snapshots/" 2>/dev/null || echo "  (none)"
```

### Step 2: Load and Parse Snapshot

**Read entire file:**
```bash
cat "$HOME/.config/opencode/snapshots/my-task.md"
```

**Extract key sections:**
- YAML frontmatter (ticket, status, created date)
- Task description (high-level WHAT/WHY)
- Context (current state, key decisions)
- Todo list (completed, in progress, not started)
- Reference files
- Notes

### Step 3: Set Working Context

**Load into agent memory:**
- What we're building and why
- Architectural decisions already made
- Current branch and file state
- What's completed vs what's left

**Verify current state matches snapshot:**
```bash
# Check if we're on the right branch
git branch --show-current

# Check if mentioned files exist
ls -la [reference files from snapshot]

# If branch/files don't match, alert user
```

### Step 4: Resume Work

**Find first incomplete todo:**
- Look for first `[ ]` item in "In Progress" section
- If "In Progress" is empty, look in "Not Started"

**Present status to user:**
```
✅ Snapshot loaded: my-task.md
   Created: 2025-11-14T15:42:00Z
   Ticket: VS-1234
   Status: in_progress

📋 Task: Add user settings update endpoint with audit logging

Current State:
- Branch: feature/VS-1234-user-settings
- Files Changed: lib/api/user_settings.ex, priv/repo/migrations/...
- Last Action: Created user_settings_audit migration, passed tests

Next Steps:
- [ ] Create UserSettings type with validation
  - [ ] Define UserSettings schema
  - [ ] Add changeset with validation
  - [ ] Run test agent
  - [ ] Run lint agent
  - [ ] Run commit agent

Ready to continue? (yes/no)
```

**Wait for user confirmation before proceeding.**

### Step 5: Continue Execution

**Once user confirms:**
- Start working on the first incomplete todo item
- Follow the atomic workflow (code → test → lint → commit)
- Update snapshot periodically as work progresses (suggest every 2-3 todos completed)

**Offer to update snapshot:**
```
Progress update: Completed 3 more todos!

Update snapshot to save progress? (yes/no)
  /snapshot:create my-task (overwrites existing)
```

</workflow>

<verification>

**Before starting work, verify:**
1. ✅ Snapshot file exists and is readable
2. ✅ Git branch matches snapshot (or ask to switch/create)
3. ✅ Reference files exist where expected
4. ✅ Working directory is clean (no uncommitted changes that might conflict)

**If discrepancies found:**
```
⚠️  Warning: Current state doesn't match snapshot!

Snapshot expects:
- Branch: feature/VS-1234-user-settings
- Files: lib/api/user_settings.ex (new)

Current state:
- Branch: master
- Files: (clean working directory)

Actions:
1. Create/switch to branch: git checkout -b feature/VS-1234-user-settings
2. Verify snapshot is still relevant
3. Proceed with caution

Continue anyway? (yes/no)
```

</verification>

<principles>

- **Verify before executing** - Don't blindly follow stale snapshots
- **Preserve context** - Load ALL decisions and rationale into memory
- **Atomic workflow** - Continue following test → lint → commit pattern
- **User confirmation** - Always confirm before starting work
- **Update snapshots** - Suggest updating after significant progress

</principles>

<examples>

**Successful resume:**
```
$ /snapshot:resume skills-migration

✅ Snapshot loaded: skills-migration.md
   Created: 2025-11-14T16:15:00Z
   Status: in_progress

📋 Task: Migrate from Claude Code to OpenCode with Skills-based architecture

Current State:
- Branch: master
- Last Action: Deleted Claude Code configuration

Next Steps:
- [ ] Create skills directory structure
- [ ] Extract backend-first-workflow skill
- [ ] Extract atomic-git-workflow skill

Ready to continue? yes

Great! Let's continue. Starting with: Create skills directory structure...
```

**Snapshot not found:**
```
$ /snapshot:resume nonexistent

❌ Snapshot not found: nonexistent

Available snapshots:
  skills-migration.md
  my-task.md
  user-settings.md
```

**State mismatch:**
```
$ /snapshot:resume my-task

⚠️  Warning: Branch mismatch!

Snapshot expects: feature/VS-1234-user-settings
Current branch: master

Switch to correct branch? (yes/no)
```

</examples>
