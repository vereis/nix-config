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
  # GNOME with D-Bus API
  if [ "${1:-}" = "region" ]; then
    # SelectArea returns x, y, width, height as a tuple
    if ! area=$(@gdbus@ call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.SelectArea 2>&1); then
      exit 0
    fi
    # Parse the returned tuple: (x, y, width, height)
    # Remove parentheses and split by comma
    area_clean=$(echo "$area" | tr -d '()' | tr ',' ' ')
    read -r x y width height <<<"$area_clean"

    # Take screenshot of selected area
    result=$(@gdbus@ call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.ScreenshotArea "$x" "$y" "$width" "$height" false "$filename")
    if [[ ! $result =~ "true" ]]; then
      @notify-send@ -u critical "Screenshot failed" "Could not capture region"
      exit 1
    fi
  else
    # Full screenshot
    result=$(@gdbus@ call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Screenshot --method org.gnome.Shell.Screenshot.Screenshot false false "$filename")
    if [[ ! $result =~ "true" ]]; then
      @notify-send@ -u critical "Screenshot failed" "Could not capture screen"
      exit 1
    fi
  fi
fi

@wl-copy@ <"$filename"
@notify-send@ "Screenshot saved" "$filename"
