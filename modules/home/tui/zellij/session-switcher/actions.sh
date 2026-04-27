#!/usr/bin/env bash
set -euo pipefail

check_dependencies() {
  local missing=()

  for command in date grep head jq sed tr zellij; do
    if ! command -v "$command" >/dev/null 2>&1; then
      missing+=("$command")
    fi
  done

  if ((${#missing[@]} > 0)); then
    printf 'missing dependencies: %s\n' "${missing[*]}" >&2
    exit 1
  fi
}

list_sessions() {
  local current_session

  current_session="$({
    zellij list-sessions --no-formatting |
      sed -n 's/^\(.*\) \[Created .* ago\] (current)$/\1/p'
  } || true)"

  if [[ -n $current_session ]]; then
    printf '%s\n' "$current_session"
    zellij list-sessions --short | grep -vxF "$current_session" || true
  else
    zellij list-sessions --short
  fi
}

preview_session() {
  # Show a live preview of a session by dumping one terminal pane from it.
  local session_name="${1-}"
  local pane_id screen_dump

  if [[ -z $session_name ]]; then
    exit 0
  fi

  # Prefer a normal terminal pane and avoid previewing the picker itself.
  pane_id="$(zellij -s "$session_name" action list-panes --json --all --command --state 2>/dev/null |
    jq -r '
    [ .[]
      | select(.is_plugin | not)
      | select(.exited | not)
      | select(.is_selectable == true)
      | select(((.pane_command // "") | contains("zellij-session-picker")) | not)
    ]
    | sort_by([
        (if .is_focused then 0 else 1 end),
        (if .is_floating then 1 else 0 end)
      ])
    | .[0].id // empty
  ' 2>/dev/null || true)"

  if [[ -n $pane_id ]]; then
    screen_dump="$(zellij -s "$session_name" action dump-screen --ansi --pane-id "terminal_$pane_id" 2>/dev/null || true)"
  else
    screen_dump=""
  fi

  # If we couldn't identify a good pane, fall back to Zellij's default dump.
  if [[ -z $screen_dump ]]; then
    screen_dump="$(zellij -s "$session_name" action dump-screen --ansi 2>/dev/null || true)"
  fi

  printf '%s' "$screen_dump"
}

delete_session() {
  local session_name="${1-}"

  if [[ -z $session_name ]]; then
    exit 0
  fi

  zellij delete-session "$session_name" >/dev/null 2>&1 || zellij kill-session "$session_name" >/dev/null 2>&1 || true
}

new_session() {
  local session_name

  session_name="session-$(date +%Y%m%d-%H%M%S)"

  zellij attach --create-background "$session_name" >/dev/null 2>&1 || true
  zellij action switch-session "$session_name"
}

pick_session() {
  local selection

  selection="$("${HOME}"/.local/bin/tv sessions --hide-help-panel | tr -d '\r' | head -n1)"

  if [[ -z $selection ]]; then
    exit 0
  fi

  exec zellij action switch-session "$selection"
}

check_dependencies

case "${1-}" in
list)
  list_sessions
  ;;
preview)
  preview_session "${2-}"
  ;;
delete)
  delete_session "${2-}"
  ;;
new)
  new_session
  ;;
pick)
  pick_session
  ;;
*)
  printf 'usage: %s {list|preview <session>|delete <session>|new|pick}\n' "$0" >&2
  exit 1
  ;;
esac
