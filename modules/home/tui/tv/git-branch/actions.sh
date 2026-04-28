#!/usr/bin/env bash
set -euo pipefail

resolve_repo() {
  if [[ -n ${GIT_BRANCH_SWITCHER_REPO:-} ]]; then
    printf '%s\n' "$GIT_BRANCH_SWITCHER_REPO"
    return 0
  fi

  if common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
    printf '%s\n' "$common_dir"
    return 0
  fi

  if [[ -d .bare ]]; then
    printf '%s/.bare\n' "$PWD"
    return 0
  fi

  printf 'not inside a git worktree or worktrunk container\n' >&2
  return 1
}

focused_pane_cwd() {
  if [[ -z ${ZELLIJ:-} ]]; then
    return 1
  fi

  zellij action list-panes --json 2>/dev/null |
    jq -r '.[] | select(.is_focused == true) | .pane_cwd // empty' |
    head -n1
}

resolve_repo_from_focused_pane() {
  local cwd wt_repo

  if wt_repo=$(resolve_repo 2>/dev/null); then
    printf '%s\n' "$wt_repo"
    return 0
  fi

  cwd=$(focused_pane_cwd)
  if [[ -n $cwd ]]; then
    if wt_repo=$(cd "$cwd" && resolve_repo 2>/dev/null); then
      printf '%s\n' "$wt_repo"
      return 0
    fi
  fi

  printf 'not inside a git worktree or worktrunk container\n' >&2
  return 1
}

list_branches() {
  local wt_repo=$1 repo_name viewer branch
  local local_branches=() pr_rows=() row author decision number
  declare -A checked_out=()
  declare -A pr_branch=()

  while IFS= read -r branch; do
    checked_out[$branch]=1
    local_branches+=("$branch")
  done < <(git --git-dir="$wt_repo" worktree list --porcelain | sed -n 's|^branch refs/heads/||p')

  repo_name=$(repo_name_from_origin "$wt_repo")
  if [[ -n $repo_name ]]; then
    viewer=$(gh api user --jq .login 2>/dev/null || true)
    if [[ -z $viewer ]]; then
      return 0
    fi

    mapfile -t pr_rows < <(gh pr list \
      --repo "$repo_name" \
      --state open \
      --search "involves:$viewer OR review-requested:$viewer" \
      --limit 100 \
      --json number,headRefName,author,reviewDecision \
      --jq '.[] | [.headRefName, .author.login, (if (.reviewDecision == null or .reviewDecision == "") then "PENDING" else .reviewDecision end), (.number | tostring)] | @tsv' \
      2>/dev/null || true)

    for row in "${pr_rows[@]}"; do
      IFS=$'\t' read -r branch author decision number <<<"$row"
      pr_branch[$branch]=1
    done
  fi

  for branch in "${local_branches[@]}"; do
    if [[ -z ${pr_branch[$branch]:-} ]]; then
      print_entry "$branch" "" "" "" true
    fi
  done

  for row in "${pr_rows[@]}"; do
    IFS=$'\t' read -r branch author decision number <<<"$row"
    print_entry "$branch" "$author" "$decision" "$number" "${checked_out[$branch]:-}"
  done
}

print_entry() {
  local branch=$1 author=$2 decision=$3 number=$4 checked_marker=${5:-} display_branch

  display_branch=$branch
  if ((${#display_branch} > 64)); then
    display_branch="${display_branch:0:61}..."
  fi

  if [[ -n $checked_marker ]]; then
    display_branch="* $display_branch"
  fi

  case $decision in
  APPROVED) decision=approved ;;
  CHANGES_REQUESTED) decision=changes ;;
  REVIEW_REQUIRED) decision=review ;;
  PENDING) decision=pending ;;
  esac

  printf '%s@@@%-64s  %-20s  %s@@@%s\n' "$branch" "$display_branch" "$author" "$decision" "$number"
}

repo_name_from_origin() {
  local wt_repo=$1 origin repo_name canonical_name

  origin=$(git --git-dir="$wt_repo" remote get-url origin 2>/dev/null || true)
  origin=${origin%.git}

  case $origin in
  git@github.com:*) repo_name=${origin#git@github.com:} ;;
  https://github.com/*) repo_name=${origin#https://github.com/} ;;
  ssh://git@github.com/*) repo_name=${origin#ssh://git@github.com/} ;;
  esac

  if [[ -z ${repo_name:-} ]]; then
    return 0
  fi

  canonical_name=$(gh repo view "$repo_name" --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
  printf '%s\n' "${canonical_name:-$repo_name}"
}

layout_for_repo() {
  local wt_repo=$1 repo_name repo layout_dir layout

  layout_dir=${XDG_CONFIG_HOME:-$HOME/.config}/zellij/layouts
  repo_name=$(repo_name_from_origin "$wt_repo")
  repo=${repo_name##*/}

  if [[ -n $repo ]]; then
    layout=$layout_dir/$repo.kdl
    if [[ -f $layout ]]; then
      printf '%s\n' "$layout"
      return 0
    fi
  fi

  printf '%s\n' "$layout_dir/workspace.kdl"
}

repo_label() {
  local wt_repo=$1 repo_name repo

  repo_name=$(repo_name_from_origin "$wt_repo")
  repo=${repo_name##*/}
  printf '%s\n' "${repo:-workspace}"
}

truncate_branch() {
  local branch=$1 max_length=14

  if ((${#branch} > max_length)); then
    printf '%s...\n' "${branch:0:max_length-3}"
  else
    printf '%s\n' "$branch"
  fi
}

tab_name_for_branch() {
  local wt_repo=$1 branch=$2

  printf '%s - %s\n' "$(repo_label "$wt_repo")" "$(truncate_branch "$branch")"
}

open_workspace_tab() {
  local wt_repo=$1 branch=$2 worktree_path=$3 origin_pane_id=${4:-}
  local layout tab_name

  if [[ -n ${ZELLIJ:-} ]]; then
    tab_name=$(tab_name_for_branch "$wt_repo" "$branch")
    layout=$(layout_for_repo "$wt_repo")
    zellij action new-tab --name "$tab_name" --cwd "$worktree_path" --layout "$layout"

    if [[ -n $origin_pane_id ]]; then
      zellij action close-pane --pane-id "$origin_pane_id"
    fi
  else
    printf '%s\n' "$worktree_path"
  fi
}

escape_kdl_string() {
  local value=$1

  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s\n' "$value"
}

workspace_layout_string() {
  local layout=$1 worktree_path=$2 escaped_cwd

  escaped_cwd=$(escape_kdl_string "$worktree_path")
  sed "1a\\
            cwd \"$escaped_cwd\"" "$layout"
}

replace_workspace_tab() {
  local wt_repo=$1 branch=$2 worktree_path=$3
  local layout tab_name layout_string

  if [[ -z ${ZELLIJ:-} ]]; then
    printf '%s\n' "$worktree_path"
    return 0
  fi

  tab_name=$(tab_name_for_branch "$wt_repo" "$branch")
  layout=$(layout_for_repo "$wt_repo")
  layout_string=$(workspace_layout_string "$layout" "$worktree_path")

  zellij action rename-tab "$tab_name"
  zellij action override-layout --layout-string "$layout_string" --apply-only-to-active-tab
}

preview_branch() {
  local wt_repo=$1 entry=$2 branch number repo_name default_branch

  branch=${entry%%@@@*}
  number=${entry##*@@@}
  if [[ $number == "$entry" ]]; then
    number=""
  fi
  branch=${branch%%[[:space:]]*}

  if [[ -z $branch ]]; then
    exit 0
  fi

  repo_name=$(repo_name_from_origin "$wt_repo")
  if [[ -n $repo_name && -n $number ]]; then
    GH_FORCE_TTY=100% gh pr view "$number" --repo "$repo_name" 2>/dev/null || true
    exit 0
  fi

  default_branch=$(git --git-dir="$wt_repo" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  default_branch=${default_branch#refs/heads/}

  if [[ -n $default_branch ]]; then
    git --git-dir="$wt_repo" diff --stat "$default_branch...$branch" 2>/dev/null || true
    printf '\n'
  fi

  git --git-dir="$wt_repo" log --oneline --decorate --max-count=30 "$branch" 2>/dev/null || true
}

parse_entry_branch() {
  local entry=$1 branch

  branch=${entry%%@@@*}
  branch=${branch%%[[:space:]]*}
  printf '%s\n' "$branch"
}

parse_entry_number() {
  local entry=$1 number

  number=${entry##*@@@}
  if [[ $number == "$entry" ]]; then
    number=""
  fi
  printf '%s\n' "$number"
}

open_branch() {
  local wt_repo=$1 entry=$2 branch number repo_name

  branch=$(parse_entry_branch "$entry")
  number=$(parse_entry_number "$entry")
  repo_name=$(repo_name_from_origin "$wt_repo")

  if [[ -z $branch || -z $repo_name ]]; then
    exit 0
  fi

  if [[ -n $number ]]; then
    gh pr view "$number" --repo "$repo_name" --web >/dev/null 2>&1 || true
  elif ! gh pr view "$branch" --repo "$repo_name" --web >/dev/null 2>&1; then
    gh browse --repo "$repo_name" --branch "$branch" >/dev/null 2>&1 || true
  fi
}

remove_branch() {
  local wt_repo=$1 entry=$2 branch

  branch=$(parse_entry_branch "$entry")
  if [[ -z $branch ]]; then
    exit 0
  fi

  wt -C "$wt_repo" remove "$branch" --no-delete-branch --foreground >/dev/null 2>&1 || true
}

switch_branch() {
  local wt_repo=$1 branch=$2 origin_pane_id=${ZELLIJ_PANE_ID:-}
  local number switch_output switch_json worktree_path wt_target

  branch=$(parse_entry_branch "$2")
  number=$(parse_entry_number "$2")

  if [[ -z $branch ]]; then
    exit 0
  fi

  wt_target=$branch
  if [[ -n $number ]]; then
    wt_target=pr:$number
  fi

  switch_output=$(wt -C "$wt_repo" switch "$wt_target" --no-cd --format json)
  switch_json=${switch_output%%$'\n'*}
  worktree_path=$(jq -r '.path // .worktree_path // empty' <<<"$switch_json")

  if [[ -z $worktree_path ]]; then
    printf 'could not determine worktree path from wt output:\n%s\n' "$switch_output" >&2
    exit 1
  fi

  open_workspace_tab "$wt_repo" "$branch" "$worktree_path" "$origin_pane_id"
}

dev_workspace() {
  local wt_repo branch worktree_path

  wt_repo=$(resolve_repo)
  branch=${1:-}

  if [[ -n $branch ]]; then
    switch_branch "$wt_repo" "$branch"
    return 0
  fi

  worktree_path=$(git rev-parse --path-format=absolute --show-toplevel 2>/dev/null || true)
  branch=$(git branch --show-current 2>/dev/null || true)

  if [[ -z $worktree_path || -z $branch ]]; then
    printf 'usage: %s dev [branch]\n' "$0" >&2
    printf 'dev without a branch must be run inside a worktree\n' >&2
    exit 1
  fi

  replace_workspace_tab "$wt_repo" "$branch" "$worktree_path"
}

pick_branch() {
  local selection wt_repo

  wt_repo=$(resolve_repo_from_focused_pane)
  selection=$(GIT_BRANCH_SWITCHER_REPO="$wt_repo" "${HOME}/.local/bin/tv" branches --hide-help-panel | tr -d '\r' | head -n1)
  switch_branch "$wt_repo" "$selection"
}

case "${1-}" in
list)
  list_branches "$(resolve_repo)"
  ;;
preview)
  preview_branch "$(resolve_repo)" "${2-}"
  ;;
open)
  open_branch "$(resolve_repo)" "${2-}"
  ;;
remove)
  remove_branch "$(resolve_repo)" "${2-}"
  ;;
switch)
  switch_branch "$(resolve_repo)" "${2-}"
  ;;
dev)
  dev_workspace "${2-}"
  ;;
pick)
  pick_branch
  ;;
*)
  printf 'usage: %s {list|preview <branch>|open <branch>|remove <branch>|switch <branch>|dev [branch]|pick}\n' "$0" >&2
  exit 1
  ;;
esac
