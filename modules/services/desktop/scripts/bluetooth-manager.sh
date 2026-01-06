#!/usr/bin/env bash

# Get list of bluetooth devices with their status
get_devices() {
    @bluetoothctl@ devices | while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        if @bluetoothctl@ info "$mac" | grep -q "Connected: yes"; then
            echo "🔵 $name ($mac) [CONNECTED]"
        else
            echo "⚫ $name ($mac) [DISCONNECTED]"
        fi
    done
}

# Main menu
while true; do
    # Build device list array
    devices=()
    while IFS= read -r device; do
        devices+=("$device")
    done < <(get_devices)
    
    choice=$(@gum@ choose --header "Bluetooth Manager (Press ESC to close)" \
        "Scan for devices" \
        "Pair new device" \
        "${devices[@]}" \
        "Exit")
    
    # Exit if user pressed Escape (empty choice) or selected Exit
    if [ -z "$choice" ] || [ "$choice" = "Exit" ]; then
        break
    elif [ "$choice" = "Scan for devices" ]; then
        @gum@ spin --spinner dot --title "Scanning for devices..." -- sleep 5 &
        @bluetoothctl@ scan on 2>&1 | grep -v "SetDiscoveryFilter" &
        SCAN_PID=$!
        sleep 5
        kill $SCAN_PID 2>/dev/null
        @bluetoothctl@ scan off 2>&1 | grep -v "Failed to stop discovery" >/dev/null
    elif [ "$choice" = "Pair new device" ]; then
        # Show discovered devices
        devices=$(@bluetoothctl@ devices | @gum@ choose --header "Select device to pair (ESC to cancel)")
        # Skip if user pressed Escape
        if [ -n "$devices" ]; then
            mac=$(echo "$devices" | awk '{print $2}')
            @gum@ spin --spinner dot --title "Pairing with device..." -- @bluetoothctl@ pair "$mac"
            @bluetoothctl@ trust "$mac"
            @gum@ style --foreground 212 "Device paired successfully!"
            sleep 1
        fi
    else
        # Extract MAC address from selection (between parentheses)
        mac=$(echo "$choice" | sed -n 's/.*(\([0-9A-F:]*\)).*/\1/p')
        
        if [ -z "$mac" ]; then
            @gum@ style --foreground 196 "Error: Could not extract MAC address"
            sleep 1
            continue
        fi
        
        if echo "$choice" | grep -q "\[CONNECTED\]"; then
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
                "Disconnect" \
                "Back")
            
            # Skip if user pressed Escape or Back
            if [ -n "$action" ] && [ "$action" = "Disconnect" ]; then
                @bluetoothctl@ disconnect "$mac"
                @gum@ style --foreground 212 "Device disconnected!"
                sleep 1
            fi
        else
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
                "Connect" \
                "Remove device" \
                "Back")
            
            # Skip if user pressed Escape or Back
            if [ -n "$action" ]; then
                if [ "$action" = "Connect" ]; then
                    # Extract device name without MAC
                    device_name=$(echo "$choice" | sed 's/ *([^)]*) *\[.*\]//')
                    @gum@ spin --spinner dot --title "Connecting..." -- @bluetoothctl@ connect "$mac" 2>&1 | grep -v "SetDiscoveryFilter" >/dev/null
                    @gum@ style --foreground 212 "Connected to $device_name"
                    sleep 1
                elif [ "$action" = "Remove device" ]; then
                    @bluetoothctl@ remove "$mac" 2>&1 >/dev/null
                    @gum@ style --foreground 212 "Device removed!"
                    sleep 1
                fi
            fi
        fi
    fi
done
