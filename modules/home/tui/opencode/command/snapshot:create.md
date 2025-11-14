---
description: Create a task snapshot for resuming work later or handing off to another agent
mode: agent
tools:
  write: true
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

# Task Snapshot Creator

<purpose>
Capture current task state in a resumable format. Filters out noise (test output, build logs, failed attempts) and focuses on:
- WHAT we're building and WHY
- Key architectural decisions made
- Current progress state
- Atomic todo list following backend-first + test/lint/commit workflow
</purpose>

<snapshot-format>
```markdown
---
created: [ISO 8601 timestamp]
ticket: [TICKET-123 or null]
status: [planning | in_progress | blocked | ready_to_start]
---

# Task: [High-level task description]

## Context

### What We're Building
[2-3 sentence summary of the feature/fix/task - the WHAT and WHY, not HOW]

### Current State
- **Branch**: [git branch name]
- **Files Changed**: [list of modified files]
- **Last Action**: [what was just completed]
- **Blockers**: [None or list blockers]

### Key Decisions Made
- [Decision 1 with rationale]
- [Decision 2 with rationale]
- ...

## Todo List

Following atomic commit workflow (code → test → lint → commit per semantic change):

### Completed ✅
- [x] [Task 1]
  - [x] [Implementation step]
  - [x] Run test agent
  - [x] Run lint agent
  - [x] Run commit agent

### In Progress 🔄
- [ ] [Current task being worked on]
  - [ ] [Next step]
  - [ ] Run test agent
  - [ ] Run lint agent
  - [ ] Run commit agent

### Not Started 📋
- [ ] [Future task 1]
  - [ ] [Implementation step]
  - [ ] Run test agent
  - [ ] Run lint agent
  - [ ] Run commit agent

## Reference Files
- [file1.ex] - [brief description of relevance]
- [file2_test.exs] - [test suite]
- ...

## Notes
- [Important reminders about workflow/standards]
- [Known gotchas or edge cases]
- [Dependencies or prerequisites]
```
</snapshot-format>

<workflow>

### Step 0: Validate Arguments

**Check if name provided:**
```bash
if [ -z "$ARGUMENTS" ]; then
  echo "❌ Error: Snapshot name required"
  echo ""
  echo "Usage: /snapshot:create <name>"
  echo ""
  echo "Example: /snapshot:create my-task"
  exit 1
fi
```

### Step 1: Gather Context

**Detect ticket/issue:**
```bash
# Check branch name for ticket
git branch --show-current

# Check recent commits
git log --oneline -5

# If JIRA ticket found, fetch details
jira issue view TICKET-123

# If GitHub issue, fetch details
gh issue view 123
```

**Analyze current state:**
```bash
# What files changed
git status
git diff --name-only
git diff --cached --name-only

# What's the current branch
git branch --show-current

# Recent work
git log --oneline -3
```

### Step 2: Extract Task Description from Chat History

**Scan conversation for:**
- Initial user request (what they asked for)
- Clarifications made during discussion
- Architectural decisions agreed upon
- Backend-first workflow steps identified

**EXCLUDE from summary:**
- Test output (verbose, noisy)
- Lint errors (too detailed)
- Build failures (implementation noise)
- Failed approaches (focus on decisions, not mistakes)
- Exploratory code reads (unless they led to decisions)

**INCLUDE in summary:**
- High-level WHAT and WHY
- Key technical decisions (Ecto changesets, JSONB audit, etc.)
- Patterns being followed (RESTful, backend-first, etc.)
- Reference implementations found

### Step 3: Build Atomic Todo List

**Follow backend-first workflow:**
1. Database/Schema changes
2. Model/Type definitions
3. Business logic implementation
4. API/Interface layer
5. Frontend/UI changes

**Each todo item MUST include:**
- Implementation step (one semantic change)
- Run test agent
- Run lint agent
- Run commit agent

**Categorize todos:**
- ✅ Completed (with all 4 steps done)
- 🔄 In Progress (currently working on)
- 📋 Not Started (future work)

### Step 4: Generate Snapshot File

**Filename handling:**
- If user provides a name: use that name (e.g., `/snapshot:create my-task`)
- If no name provided: auto-generate `task-[TICKET-123]-[timestamp].md`
- Extension: Always append `.md` if not present

**Storage location:**
- Primary: `$HOME/.config/opencode/snapshots/[filename].md`
- Fallback: `/tmp/[filename].md` (if snapshots dir doesn't exist or isn't writable)
- Create `$HOME/.config/opencode/snapshots/` directory if it doesn't exist

**Write process:**
```bash
# Create snapshots directory if needed
mkdir -p "$HOME/.config/opencode/snapshots"

# Write snapshot file
cat > "$HOME/.config/opencode/snapshots/my-task.md" <<EOF
[snapshot content]
EOF
```

**Show user:**
```
✅ Task snapshot created: my-task.md
   Location: ~/.config/opencode/snapshots/my-task.md

Resume this task later with:
  /snapshot:resume my-task
```

</workflow>

<principles>

- **Focus on WHAT, not HOW** - High-level intent, not implementation details
- **Decisions over history** - What was decided, not how we got there
- **Atomic breakdown** - Each todo = one semantic change + test + lint + commit
- **Backend-first** - Follow the workflow religiously in todo ordering
- **Resumable** - Another agent should be able to pick this up cold

</principles>

<examples>

See test snapshot at: /tmp/snapshot-format-test.md

</examples>
