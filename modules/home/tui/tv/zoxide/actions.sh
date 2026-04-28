#!/usr/bin/env bash
set -euo pipefail

check_dependencies() {
  local missing=()

  for command in git grep head jq tr zellij zoxide; do
    if ! command -v "$command" >/dev/null 2>&1; then
      missing+=("$command")
    fi
  done

  if ((${#missing[@]} > 0)); then
    printf 'missing dependencies: %s\n' "${missing[*]}" >&2
    exit 1
  fi
}

list_dirs() {
  zoxide query -l
}

preview_dir() {
  local dir="${1-}"

  if [[ -z $dir ]]; then
    exit 0
  fi

  printf '%s\n\n' "$dir"
  zoxide query -s -l | grep -F -- "$dir" || true

  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '\n'
    git -C "$dir" status --short --branch
  fi
}

target_pane() {
  local current_pane_id="${ZELLIJ_PANE_ID#terminal_}"

  zellij action list-panes --json |
    jq -r --arg current_pane_id "$current_pane_id" '
      [ .[]
        | select(.is_plugin | not)
        | select(.exited | not)
        | select(.is_selectable == true)
        | select((.id | tostring) != $current_pane_id)
        | select(((.pane_command // "") | contains("zoxide-picker")) | not)
        | select(.is_focused == true)
      ]
      | sort_by(if .is_floating then 0 else 1 end)
      | .[0].id // empty
    '
}

nu_string() {
  local value="$1"

  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

jump_dir() {
  local dir="${1-}" pane_id command

  if [[ -z $dir ]]; then
    exit 0
  fi

  pane_id="$(target_pane)"
  if [[ -z $pane_id ]]; then
    exit 1
  fi

  command="cd $(nu_string "$dir")"
  zellij action write-chars --pane-id "$pane_id" "$command"
  zellij action send-keys --pane-id "$pane_id" Enter
  zellij action close-pane
}

pick_dir() {
  local selection

  selection="$("${HOME}"/.local/bin/tv zoxide --hide-help-panel | tr -d '\r' | head -n1)"
  jump_dir "$selection"
}

check_dependencies

case "${1-}" in
list)
  list_dirs
  ;;
preview)
  preview_dir "${2-}"
  ;;
jump)
  jump_dir "${2-}"
  ;;
pick)
  pick_dir
  ;;
*)
  printf 'usage: %s {list|preview|jump|pick}\n' "$0" >&2
  exit 2
  ;;
esac
