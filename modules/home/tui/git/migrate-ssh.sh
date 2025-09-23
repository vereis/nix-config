#!/bin/sh
if git remote -v | grep "https" >/dev/null 2>&1; then
  git remote set-url origin "$(git remote -v | grep push | cut -f 2 | cut -f 1 -d ' ' | sed -En "s/https:\/\/github.com\//git@github.com:/p")"
  echo "ok."
else
  echo "Remote not configured for GitHub HTTPS, cannot migrate."
fi
