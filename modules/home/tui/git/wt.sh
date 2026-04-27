#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage:
  git wt clone <source> [destination]
  git wt <worktrunk args...>

git wt clone creates this layout:
  destination/
    .bare/
    <default-branch>/
EOF
}

derive_destination() {
  local source=$1
  local name

  source=${source%/}
  name=${source##*/}
  name=${name%.git}

  if [[ -z $name || $name == . || $name == / ]]; then
    printf 'could not derive destination from source: %s\n' "$source" >&2
    return 1
  fi

  printf '%s\n' "$name"
}

maybe_github_ssh_url() {
  local source=$1
  local extra owner path protocol repo

  if [[ $source != https://github.com/* ]]; then
    printf '%s\n' "$source"
    return 0
  fi

  path=${source#https://github.com/}
  path=${path%/}
  path=${path%.git}
  IFS=/ read -r owner repo extra <<<"$path"
  if [[ -z $owner || -z $repo || -n ${extra:-} ]]; then
    printf '%s\n' "$source"
    return 0
  fi

  protocol=$(gh config get git_protocol --host github.com 2>/dev/null || true)
  protocol=${protocol//$'\n'/}
  protocol=${protocol//$'\r'/}
  if [[ $protocol != ssh ]]; then
    printf '%s\n' "$source"
    return 0
  fi

  printf 'git@github.com:%s/%s.git\n' "$owner" "$repo"
}

clone_worktrunk_repo() {
  if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage >&2
    return 2
  fi

  local source=$1
  local destination=${2:-}
  local bare_dir clone_source default_branch worktree_path

  if [[ -z $destination ]]; then
    destination=$(derive_destination "$source")
  fi

  if [[ -e $destination && -n $(find "$destination" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
    printf 'destination already exists and is not empty: %s\n' "$destination" >&2
    return 1
  fi

  mkdir -p "$destination"
  bare_dir=$destination/.bare
  clone_source=$(maybe_github_ssh_url "$source")

  git clone --bare --filter=blob:none "$clone_source" "$bare_dir"
  git --git-dir="$bare_dir" remote set-url origin "$clone_source"
  git --git-dir="$bare_dir" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git --git-dir="$bare_dir" fetch origin --prune

  default_branch=$(git --git-dir="$bare_dir" symbolic-ref --quiet --short HEAD)
  default_branch=${default_branch#refs/heads/}
  worktree_path=$destination/$default_branch

  git --git-dir="$bare_dir" worktree add "$worktree_path" "$default_branch"

  printf 'created bare repo: %s\n' "$bare_dir"
  printf 'created default worktree: %s\n' "$worktree_path"
}

delegate_worktrunk() {
  if [[ -d .bare ]]; then
    exec wt -C .bare "$@"
  fi

  exec wt "$@"
}

case "${1:-}" in
"" | -h | --help)
  usage
  ;;
clone)
  shift
  clone_worktrunk_repo "$@"
  ;;
*)
  delegate_worktrunk "$@"
  ;;
esac
