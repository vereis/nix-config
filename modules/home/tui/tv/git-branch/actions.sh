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
  local wt_repo=$1 repo_name viewer

  git --git-dir="$wt_repo" worktree list --porcelain |
    sed -n 's|^branch refs/heads/||p' |
    while IFS= read -r branch; do
      print_entry "$branch" "" "" ""
    done

  repo_name=$(repo_name_from_origin "$wt_repo")
  if [[ -n $repo_name ]]; then
    viewer=$(gh api user --jq .login 2>/dev/null || true)
    if [[ -z $viewer ]]; then
      return 0
    fi

    gh pr list \
      --repo "$repo_name" \
      --state open \
      --search "involves:$viewer OR review-requested:$viewer" \
      --limit 50 \
      --json number,headRefName,author,reviewDecision \
      --jq '.[] | [.headRefName, .author.login, (if (.reviewDecision == null or .reviewDecision == "") then "PENDING" else .reviewDecision end), (.number | tostring)] | @tsv' \
      2>/dev/null |
      while IFS=$'\t' read -r branch author decision number; do
        print_entry "$branch" "$author" "$decision" "$number"
      done || true
  fi
}

print_entry() {
  local branch=$1 author=$2 decision=$3 number=$4 display_branch

  display_branch=$branch
  if ((${#display_branch} > 64)); then
    display_branch="${display_branch:0:61}..."
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

switch_branch() {
  local wt_repo=$1 branch=$2 origin_pane_id=${ZELLIJ_PANE_ID:-}
  local switch_output switch_json worktree_path tab_name

  branch=${branch%%@@@*}
  branch=${branch%%[[:space:]]*}

  if [[ -z $branch ]]; then
    exit 0
  fi

  switch_output=$(wt -C "$wt_repo" switch "$branch" --no-cd --format json)
  switch_json=${switch_output%%$'\n'*}
  worktree_path=$(jq -r '.path // .worktree_path // empty' <<<"$switch_json")

  if [[ -z $worktree_path ]]; then
    printf 'could not determine worktree path from wt output:\n%s\n' "$switch_output" >&2
    exit 1
  fi

  if [[ -n ${ZELLIJ:-} ]]; then
    tab_name=${branch//\//-}
    zellij action new-tab --name "$tab_name" --cwd "$worktree_path" -- nu

    if [[ -n $origin_pane_id ]]; then
      zellij action close-pane --pane-id "$origin_pane_id"
    fi
  else
    printf '%s\n' "$worktree_path"
  fi
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
switch)
  switch_branch "$(resolve_repo)" "${2-}"
  ;;
pick)
  pick_branch
  ;;
*)
  printf 'usage: %s {list|preview <branch>|switch <branch>|pick}\n' "$0" >&2
  exit 1
  ;;
esac
