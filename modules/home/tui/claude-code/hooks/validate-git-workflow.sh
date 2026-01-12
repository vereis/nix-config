#!/usr/bin/env bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Blocked: jq is required for Claude Code hooks (install jq)" >&2
  exit 2
fi

INPUT="$(cat)"
CMD="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

# Only validate commands that can change history / branch state.
case "$CMD" in
git\ commit* | git\ push* | git\ merge* | git\ rebase* | git\ checkout* | git\ switch* | gh\ pr\ create*) ;;
*)
  exit 0
  ;;
esac

# Must be inside a work tree for these operations.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Blocked: git operation attempted outside a work tree" >&2
  exit 2
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  echo "Blocked: detached HEAD; create/switch to a branch first" >&2
  exit 2
fi

case "$BRANCH" in
main | master)
  echo "Blocked: never commit/push from $BRANCH; create a feature branch/worktree first" >&2
  exit 2
  ;;
esac

# Branch naming rules (Conventional Commit aligned)
# - feat/foo-bar
# - feat/TICKET-123
# - feat/TICKET-123-foo-bar

if echo "$BRANCH" | grep -Eq '^(feat|fix|refactor|chore|docs|test|style|perf|ci|build|revert)/[a-z0-9][a-z0-9-]*$'; then
  :
elif echo "$BRANCH" | grep -Eq '^(feat|fix|refactor|chore|docs|test|style|perf|ci|build|revert)/[A-Z][A-Z0-9]+-[0-9]+(-[a-z0-9][a-z0-9-]*)?$'; then
  :
else
  echo "Blocked: branch '$BRANCH' does not match naming rules. Use e.g. 'feat/short-kebab' or 'feat/TICKET-123' (optionally 'feat/TICKET-123-short-kebab')." >&2
  exit 2
fi

# Commit message policy (enforced for 'git commit' only)
# - Default: single-line Conventional Commit subject via -m "..."
# - Revert: allow exactly one additional -m "Refs: <sha>[, <sha>...]" line
#
# Note: We intentionally require double-quoted -m messages. This keeps parsing reliable.

if echo "$CMD" | grep -Eq '^git commit(\s|$)'; then
  if echo "$CMD" | grep -Eq '(^|\s)(-F|--file|--template)(\s|$)'; then
    echo "Blocked: commit message must be provided inline with -m (no -F/--file/--template)" >&2
    exit 2
  fi

  if ! echo "$CMD" | grep -q ' -m "'; then
    echo 'Blocked: commit message must be provided as: git commit -m "type(scope): desc"' >&2
    exit 2
  fi

  M_COUNT="$(echo "$CMD" | grep -o ' -m "' | wc -l | tr -d ' ')"

  if [ "$M_COUNT" -gt 2 ]; then
    echo "Blocked: too many -m flags. Keep commit messages short." >&2
    exit 2
  fi

  TMP1="${CMD#* -m \"}"
  MSG1="${TMP1%%\"*}"

  if [ -z "$MSG1" ]; then
    echo "Blocked: empty commit subject" >&2
    exit 2
  fi

  if [ "${#MSG1}" -gt 72 ]; then
    echo "Blocked: commit subject too long (>72 chars). Keep it short." >&2
    exit 2
  fi

  if ! echo "$MSG1" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: [^ ].+$'; then
    echo "Blocked: commit subject must follow Conventional Commits (e.g. 'feat(scope): short description')" >&2
    exit 2
  fi

  if echo "$MSG1" | grep -Eq '^revert(\([^)]+\))?: '; then
    if [ "$M_COUNT" -eq 2 ]; then
      # remainder after first closing quote
      AFTER1="${TMP1#*\"}"

      if ! echo "$AFTER1" | grep -q ' -m "'; then
        echo "Blocked: revert commits may include a second -m line for Refs" >&2
        exit 2
      fi

      TMP2="${AFTER1#* -m \"}"
      MSG2="${TMP2%%\"*}"

      if [ -z "$MSG2" ]; then
        echo "Blocked: revert Refs line must not be empty" >&2
        exit 2
      fi

      if ! echo "$MSG2" | grep -Eq '^Refs: [0-9a-f]{7,40}(, [0-9a-f]{7,40})*$'; then
        echo "Blocked: revert second line must be: Refs: <sha>[, <sha>...]" >&2
        exit 2
      fi
    fi
  else
    if [ "$M_COUNT" -ne 1 ]; then
      echo "Blocked: commit message must be single-line (one -m) unless it's a revert with Refs" >&2
      exit 2
    fi
  fi
fi

exit 0
