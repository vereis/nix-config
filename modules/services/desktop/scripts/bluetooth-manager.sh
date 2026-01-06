#!/usr/bin/env bash

# Get list of bluetooth devices with their status
get_devices() {
    @bluetoothctl@ devices | while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        if @bluetoothctl@ info "$mac" | grep -q "Connected: yes"; then
            echo "✓ $name ($mac) [CONNECTED]"
        else
            echo "✗ $name ($mac) [DISCONNECTED]"
        fi
    done
}

# Main menu
while true; do
    # Clear screen before showing menu
    clear
    
    # Build device list array
    devices=()
    while IFS= read -r device; do
        devices+=("$device")
    done < <(get_devices)
    
    choice=$(@gum@ choose --header "Bluetooth Manager (Press ESC or q to close)" \
        "Scan for devices" \
        "Pair new device" \
        "${devices[@]}" \
        "Exit")
    
    # Exit if user pressed Escape (empty choice), typed 'q', or selected Exit
    if [ -z "$choice" ] || [ "$choice" = "Exit" ] || [ "$choice" = "q" ]; then
        break
    elif [ "$choice" = "Scan for devices" ]; then
        clear
        @gum@ spin --spinner dot --title "Scanning for devices..." -- sleep 5 &
        @bluetoothctl@ scan on >/dev/null 2>&1 &
        SCAN_PID=$!
        sleep 5
        kill $SCAN_PID 2>/dev/null
        @bluetoothctl@ scan off >/dev/null 2>&1
    elif [ "$choice" = "Pair new device" ]; then
        clear
        # Show discovered devices
        devices=$(@bluetoothctl@ devices | @gum@ choose --header "Select device to pair (ESC to cancel)")
        # Skip if user pressed Escape
        if [ -n "$devices" ]; then
            mac=$(echo "$devices" | awk '{print $2}')
            @bluetoothctl@ pair "$mac" >/dev/null 2>&1
            @bluetoothctl@ trust "$mac" >/dev/null 2>&1
            clear
            @gum@ style --foreground 212 "Device paired successfully!"
            sleep 2
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
                # Extract device name without status markers, MAC, and status
                device_name=$(echo "$choice" | sed 's/^[✓✗]* *//' | sed 's/ *([^)]*) *\[.*\]//')
                @bluetoothctl@ disconnect "$mac" >/dev/null 2>&1
                clear
                @gum@ style --foreground 212 "Disconnected from $device_name"
                sleep 2
            fi
        else
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
                "Connect" \
                "Remove device" \
                "Back")
            
            # Skip if user pressed Escape or Back
            if [ -n "$action" ]; then
                if [ "$action" = "Connect" ]; then
                    # Extract device name without status markers, MAC, and status
                    device_name=$(echo "$choice" | sed 's/^[✓✗]* *//' | sed 's/ *([^)]*) *\[.*\]//')
                    @bluetoothctl@ connect "$mac" >/dev/null 2>&1
                    clear
                    @gum@ style --foreground 212 "Connected to $device_name"
                    sleep 2
                elif [ "$action" = "Remove device" ]; then
                    @bluetoothctl@ remove "$mac" >/dev/null 2>&1
                    clear
                    @gum@ style --foreground 212 "Device removed!"
                    sleep 2
                fi
            fi
        fi
    fi
done
