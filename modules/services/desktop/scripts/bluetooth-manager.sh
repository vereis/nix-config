#!/usr/bin/env bash
# Bluetooth Manager TUI - manage bluetooth devices with gum
# Dependencies: bluetoothctl, gum
# Usage: bluetooth-manager.sh
# shellcheck disable=SC2016  # Template variables are replaced by Nix pkgs.replaceVars

set -euo pipefail

# Colors (matching niri theme)
COLOR_SUCCESS=212
COLOR_MUTED=241
COLOR_ERROR=196

# Timing constants
SCAN_DURATION_SEC=10
FEEDBACK_DELAY_SEC=1

# Cleanup function for signal handling
cleanup() {
  # Stop any ongoing bluetooth scan
  echo "quit" | @bluetoothctl@ >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Helper: Extract MAC address from formatted device string
# Matches MAC format: XX:XX:XX:XX:XX:XX (uppercase or lowercase hex)
extract_mac() {
  sed -En 's/.*\(([0-9A-Fa-f:]+)\).*/\1/p'
}

# Helper: Extract device name from formatted device string
# Removes status symbol and MAC address in parentheses at end
extract_device_name() {
  sed 's/^[✓✗]* *//' | sed 's/ *([0-9A-Fa-f:]\{17\})$//'
}

# Helper: Show success message
show_success() {
  clear
  @gum@ style --foreground "$COLOR_SUCCESS" "$1"
  sleep "$FEEDBACK_DELAY_SEC"
}

# Helper: Show error message
show_error() {
  clear
  @gum@ style --foreground "$COLOR_ERROR" "$1"
  sleep "$FEEDBACK_DELAY_SEC"
}

# Helper: Remove a bluetooth device
remove_device() {
  local mac="$1"
  local device_name="$2"
  clear
  if @gum@ spin --spinner dot --title "Removing $device_name" -- bash -c 'set -euo pipefail; @bluetoothctl@ remove "$1" >/dev/null 2>&1' _ "$mac"; then
    show_success "Removed $device_name"
  else
    show_error "Failed to remove $device_name"
  fi
}

# Helper: Check if device is currently connected
is_connected() {
  local mac="$1"
  @bluetoothctl@ info "$mac" 2>/dev/null | grep -q "Connected: yes"
}

# Get list of bluetooth devices with their status
get_devices() {
  local mac name
  @bluetoothctl@ devices 2>/dev/null | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    if @bluetoothctl@ info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
      echo "$(@gum@ style --foreground "$COLOR_SUCCESS" "✓") $name ($mac)"
    else
      echo "$(@gum@ style --foreground "$COLOR_MUTED" "✗") $name ($mac)"
    fi
  done
}

# Check for bluetooth hardware at startup
if ! @bluetoothctl@ show 2>/dev/null | grep -q "Controller"; then
  show_error "No Bluetooth controller found"
  exit 1
fi

# Main menu loop
while true; do
  clear

  # Build device list array
  devices=()
  while IFS= read -r device; do
    devices+=("$device")
  done < <(get_devices)

  # Handle gum choose exit code explicitly (user may press ESC)
  choice=$(@gum@ choose --header "Bluetooth Manager (Press ESC to close)" \
    "Scan for new devices" \
    "${devices[@]}" \
    "Exit") || choice=""

  # Exit if user pressed Escape (empty choice) or selected Exit
  if [ -z "$choice" ] || [ "$choice" = "Exit" ]; then
    break
  elif [ "$choice" = "Scan for new devices" ]; then
    clear

    # Scan for devices using bluetoothctl interactively with spinner
    # After scanning, we'll just return to the main menu which will show all devices
    @gum@ spin --spinner dot --title "Scanning for bluetooth devices..." -- bash -c '
      set -euo pipefail
      (
        echo "scan on"
        sleep '"$SCAN_DURATION_SEC"'
        echo "quit"
      ) | @bluetoothctl@ >/dev/null 2>&1 || exit 0
    '

    # Return to main menu - devices list will be refreshed automatically
    continue
  else
    # Extract MAC address from selection (between parentheses)
    mac=$(echo "$choice" | extract_mac)

    if [ -z "$mac" ]; then
      show_error "Error: Could not extract MAC address"
      continue
    fi

    # Check if device is paired
    if ! @bluetoothctl@ info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
      # Device is not paired, offer to pair it
      device_name=$(echo "$choice" | extract_device_name)
      clear
      if @gum@ spin --spinner dot --title "Pairing with $device_name" -- bash -c 'set -euo pipefail; @bluetoothctl@ pair "$1" >/dev/null 2>&1 && @bluetoothctl@ trust "$1" >/dev/null 2>&1' _ "$mac"; then
        show_success "Paired with $device_name"
      else
        show_error "Failed to pair with $device_name"
      fi
      continue
    fi

    # Device is paired - show action menu based on connection status
    device_name=$(echo "$choice" | extract_device_name)

    # Re-check connection status (don't rely on stale display data)
    if is_connected "$mac"; then
      # Device is connected - offer disconnect
      action=$(@gum@ choose --header "Device: $device_name (ESC to cancel)" \
        "Disconnect" \
        "Remove device" \
        "Back") || action=""

      if [ -z "$action" ] || [ "$action" = "Back" ]; then
        continue
      fi

      if [ "$action" = "Disconnect" ]; then
        clear
        if @gum@ spin --spinner dot --title "Disconnecting from $device_name" -- bash -c 'set -euo pipefail; @bluetoothctl@ disconnect "$1" >/dev/null 2>&1' _ "$mac"; then
          show_success "Disconnected from $device_name"
        else
          show_error "Failed to disconnect from $device_name"
        fi
      elif [ "$action" = "Remove device" ]; then
        remove_device "$mac" "$device_name"
      fi
    else
      # Device is disconnected - offer connect or remove
      action=$(@gum@ choose --header "Device: $device_name (ESC to cancel)" \
        "Connect" \
        "Remove device" \
        "Back") || action=""

      if [ -z "$action" ] || [ "$action" = "Back" ]; then
        continue
      fi

      if [ "$action" = "Connect" ]; then
        clear
        if @gum@ spin --spinner dot --title "Connecting to $device_name" -- bash -c 'set -euo pipefail; @bluetoothctl@ connect "$1" >/dev/null 2>&1' _ "$mac"; then
          show_success "Connected to $device_name"
        else
          show_error "Failed to connect to $device_name"
        fi
      elif [ "$action" = "Remove device" ]; then
        remove_device "$mac" "$device_name"
      fi
    fi
  fi
done
