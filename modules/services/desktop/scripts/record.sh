#!/usr/bin/env bash
# Screen recording script for Wayland - toggle recording with notification
# Dependencies: wf-recorder, slurp, wl-copy, notify-send, makoctl
# Usage: record.sh [region]

set -euo pipefail

RECORDING_DIR="${RECORDING_DIR:-$HOME/Videos/Recordings}"

# Use XDG_RUNTIME_DIR for security (user-private, not world-writable /tmp)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
PIDFILE="$RUNTIME_DIR/wf-recorder.pid"
REGIONFILE="$RUNTIME_DIR/wf-recorder.region"
FILENAMEFILE="$RUNTIME_DIR/wf-recorder.filename"
NOTIFYIDFILE="$RUNTIME_DIR/wf-recorder.notifyid"

# Cleanup function for signal handling
cleanup() {
  rm -f "$PIDFILE" "$REGIONFILE" "$FILENAMEFILE" "$NOTIFYIDFILE"
}
trap cleanup EXIT

# If already recording, stop it
if pid=$(cat "$PIDFILE" 2>/dev/null) && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
  kill -INT "$pid"

  # Wait up to 5 seconds for wf-recorder to finish writing (50 * 0.1s)
  timeout=50
  while kill -0 "$pid" 2>/dev/null && [ $timeout -gt 0 ]; do
    sleep 0.1
    timeout=$((timeout - 1))
  done

  # Force kill if still running
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true
  fi

  # Copy file URI to clipboard (this allows pasting in most apps)
  if [ -f "$FILENAMEFILE" ]; then
    filename=$(cat "$FILENAMEFILE")
    echo "file://$filename" | @wl-copy@ -t text/uri-list
  fi

  # Dismiss the recording notification by ID (graceful failure)
  if [ -f "$NOTIFYIDFILE" ]; then
    @makoctl@ dismiss -n "$(cat "$NOTIFYIDFILE")" 2>/dev/null || true
  fi

  @notify-send@ -u low "Recording stopped" "${filename:-Recording}"
  exit 0
fi

# Clear any stale state files
rm -f "$PIDFILE" "$REGIONFILE" "$FILENAMEFILE" "$NOTIFYIDFILE"

# Get region if requested (before creating state files)
if [ "${1:-}" = "region" ]; then
  region=$(@slurp@) || exit 0
fi

# Disable EXIT trap since we're starting a new recording
trap - EXIT

mkdir -p "$RECORDING_DIR"
filename="$RECORDING_DIR/Recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
echo "$filename" >"$FILENAMEFILE"

# Save region if we captured one
if [ -n "${region:-}" ]; then
  echo "$region" >"$REGIONFILE"
fi

# Show persistent notification and save ID for dismissal
@notify-send@ -u critical -t 0 -p "Recording..." "Press hotkey again to stop" >"$NOTIFYIDFILE"

# Start recording
if [ -f "$REGIONFILE" ]; then
  region=$(cat "$REGIONFILE")
  @wf-recorder@ -g "$region" -f "$filename" &
else
  @wf-recorder@ -f "$filename" &
fi

echo $! >"$PIDFILE"
