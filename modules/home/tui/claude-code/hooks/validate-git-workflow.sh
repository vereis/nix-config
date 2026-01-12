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
# - TICKET-123/feat-foo-bar

if echo "$BRANCH" | grep -Eq '^(feat|fix|refactor|chore|docs|test|style|perf|ci|build|revert)/[a-z0-9][a-z0-9-]*$'; then
  exit 0
fi

if echo "$BRANCH" | grep -Eq '^[A-Z][A-Z0-9]+-[0-9]+/(feat|fix|refactor|chore|docs|test|style|perf|ci|build|revert)-[a-z0-9][a-z0-9-]*$'; then
  exit 0
fi

echo "Blocked: branch '$BRANCH' does not match naming rules. Use e.g. 'feat/short-kebab' or 'TICKET-123/feat-short-kebab'." >&2
exit 2
