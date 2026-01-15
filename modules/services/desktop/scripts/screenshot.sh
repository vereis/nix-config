#!/usr/bin/env bash
# Screenshot script for Wayland - captures screen or region and copies to clipboard
# Dependencies: grim+slurp (niri) or gdbus (GNOME), wl-copy, notify-send
# Usage: screenshot.sh [region]

set -euo pipefail

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$SCREENSHOT_DIR"
filename="$SCREENSHOT_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Detect desktop environment
if @pgrep@ -x mako >/dev/null 2>&1; then
  # niri with grim/slurp
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
else
  # GNOME with flameshot
  if [ "${1:-}" = "region" ]; then
    # Interactive region selection with flameshot GUI
    if ! @flameshot@ gui --path "$SCREENSHOT_DIR"; then
      exit 0
    fi
    # flameshot gui saves with its own filename format, find the most recent screenshot
    latest=$(find "$SCREENSHOT_DIR" -maxdepth 1 -name '*.png' -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [ -n "$latest" ]; then
      @wl-copy@ <"$latest"
      @notify-send@ "Screenshot saved" "$latest"
    fi
  else
    # Full screenshot
    if ! @flameshot@ full --path "$SCREENSHOT_DIR"; then
      @notify-send@ -u critical "Screenshot failed" "Could not capture screen"
      exit 1
    fi
    # Find the most recent screenshot
    latest=$(find "$SCREENSHOT_DIR" -maxdepth 1 -name '*.png' -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [ -n "$latest" ]; then
      @wl-copy@ <"$latest"
      @notify-send@ "Screenshot saved" "$latest"
    fi
  fi
fi
