#!/usr/bin/env bash
# Screenshot script for Wayland - captures screen or region and copies to clipboard
# Dependencies: grim, slurp, wl-copy, notify-send
# Usage: screenshot.sh [region]

set -euo pipefail

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$SCREENSHOT_DIR"
filename="$SCREENSHOT_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

if [ "${1:-}" = "region" ]; then
  region=$(@slurp@) || exit 0
  if ! @grim@ -g "$region" "$filename"; then
    @notify-send@ -u critical "Screenshot failed" "Could not capture region"
    exit 1
  fi
else
  if ! @grim@ "$filename"; then
    @notify-send@ -u critical "Screenshot failed" "Could not capture screen"
    exit 1
  fi
fi

@wl-copy@ <"$filename"
@notify-send@ "Screenshot saved" "$filename"
