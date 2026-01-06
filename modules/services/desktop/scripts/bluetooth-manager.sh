#!/usr/bin/env bash
# Bluetooth Manager TUI - manage bluetooth devices with gum
# Dependencies: bluetoothctl, gum
# Usage: bluetooth-manager.sh

set -euo pipefail

# Colors (matching niri theme)
COLOR_SUCCESS=212
COLOR_MUTED=241
COLOR_ERROR=196

# No temp files needed - bluetoothctl maintains device list internally

# Helper: Extract MAC address from formatted device string
extract_mac() {
  sed -n 's/.*(\([0-9A-Fa-f:]*\)).*/\1/p'
}

# Helper: Extract device name from formatted device string
extract_device_name() {
  sed 's/^[✓✗]* *//' | sed 's/ *([^)]*).*$//'
}

# Helper: Show success message
show_success() {
  clear
  @gum@ style --foreground "$COLOR_SUCCESS" "$1"
  sleep 1
}

# Helper: Show error message
show_error() {
  clear
  @gum@ style --foreground "$COLOR_ERROR" "$1"
  sleep 1
}

# Get list of bluetooth devices with their status
get_devices() {
  @bluetoothctl@ devices | while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    if @bluetoothctl@ info "$mac" | grep -q "Connected: yes"; then
      echo "$(@gum@ style --foreground "$COLOR_SUCCESS" "✓") $name ($mac)"
    else
      echo "$(@gum@ style --foreground "$COLOR_MUTED" "✗") $name ($mac)"
    fi
  done
}

# Main menu loop
while true; do
  clear

  # Build device list array
  devices=()
  while IFS= read -r device; do
    devices+=("$device")
  done < <(get_devices)

  choice=$(@gum@ choose --header "Bluetooth Manager (Press ESC to close)" \
    "Scan for new devices" \
    "${devices[@]}" \
    "Exit")

  # Exit if user pressed Escape (empty choice) or selected Exit
  if [ -z "$choice" ] || [ "$choice" = "Exit" ]; then
    break
  elif [ "$choice" = "Scan for new devices" ]; then
    clear

    # Scan for devices using bluetoothctl interactively with spinner
    # After scanning, we'll just return to the main menu which will show all devices
    @gum@ spin --spinner dot --title "Scanning for bluetooth devices..." -- sh -c '
            (
                echo "scan on"
                sleep 10
                echo "quit"
            ) | @bluetoothctl@ >/dev/null 2>&1
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
    if ! @bluetoothctl@ info "$mac" | grep -q "Paired: yes"; then
      # Device is not paired, offer to pair it
      device_name=$(echo "$choice" | extract_device_name)
      clear
      if @gum@ spin --spinner dot --title "Pairing with $device_name" -- sh -c "@bluetoothctl@ pair '$mac' >/dev/null 2>&1 && @bluetoothctl@ trust '$mac' >/dev/null 2>&1"; then
        show_success "Paired with $device_name"
      else
        show_error "Failed to pair with $device_name"
      fi
      continue
    fi

    # Device is paired - show action menu based on connection status
    device_name=$(echo "$choice" | extract_device_name)

    if echo "$choice" | grep -q "✓"; then
      # Device is connected - offer disconnect
      action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
        "Disconnect" \
        "Remove device" \
        "Back")

      if [ -z "$action" ] || [ "$action" = "Back" ]; then
        continue
      fi

      if [ "$action" = "Disconnect" ]; then
        clear
        if @gum@ spin --spinner dot --title "Disconnecting from $device_name" -- sh -c "@bluetoothctl@ disconnect '$mac' >/dev/null 2>&1"; then
          show_success "Disconnected from $device_name"
        else
          show_error "Failed to disconnect from $device_name"
        fi
      elif [ "$action" = "Remove device" ]; then
        clear
        if @gum@ spin --spinner dot --title "Removing $device_name" -- sh -c "@bluetoothctl@ remove '$mac' >/dev/null 2>&1"; then
          show_success "Device removed!"
        else
          show_error "Failed to remove device"
        fi
      fi
    else
      # Device is disconnected - offer connect or remove
      action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
        "Connect" \
        "Remove device" \
        "Back")

      if [ -z "$action" ] || [ "$action" = "Back" ]; then
        continue
      fi

      if [ "$action" = "Connect" ]; then
        clear
        if @gum@ spin --spinner dot --title "Connecting to $device_name" -- sh -c "@bluetoothctl@ connect '$mac' >/dev/null 2>&1"; then
          show_success "Connected to $device_name"
        else
          show_error "Failed to connect to $device_name"
        fi
      elif [ "$action" = "Remove device" ]; then
        clear
        if @gum@ spin --spinner dot --title "Removing $device_name" -- sh -c "@bluetoothctl@ remove '$mac' >/dev/null 2>&1"; then
          show_success "Device removed!"
        else
          show_error "Failed to remove device"
        fi
      fi
    fi
  fi
done
