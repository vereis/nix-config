#!/usr/bin/env bash

# Get list of bluetooth devices with their status
get_devices() {
    @bluetoothctl@ devices | while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        if @bluetoothctl@ info "$mac" | grep -q "Connected: yes"; then
            echo "$(@gum@ style --foreground 212 "✓") $name ($mac)"
        else
            echo "$(@gum@ style --foreground 241 "✗") $name ($mac)"
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
    
    choice=$(@gum@ choose --header "Bluetooth Manager (Press ESC to close)" \
        "Scan for devices" \
        "Pair new device" \
        "${devices[@]}" \
        "Exit")
    
    # Exit if user pressed Escape (empty choice) or selected Exit
    if [ -z "$choice" ] || [ "$choice" = "Exit" ]; then
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
        
        # Check if device is connected by looking for the green tick
        if echo "$choice" | grep -q "✓"; then
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1) (ESC to cancel)" \
                "Disconnect" \
                "Back")
            
            # Skip if user pressed Escape or Back
            if [ -n "$action" ] && [ "$action" = "Disconnect" ]; then
                # Extract device name without status markers and MAC
                device_name=$(echo "$choice" | sed 's/^[✓✗]* *//' | sed 's/ *([^)]*).*$//')
                clear
                @gum@ spin --spinner dot --title "Attempting to disconnect from $device_name" -- sh -c "@bluetoothctl@ disconnect '$mac' >/dev/null 2>&1"
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
                    # Extract device name without status markers and MAC
                    device_name=$(echo "$choice" | sed 's/^[✓✗]* *//' | sed 's/ *([^)]*).*$//')
                    clear
                    @gum@ spin --spinner dot --title "Attempting to connect to $device_name" -- sh -c "@bluetoothctl@ connect '$mac' >/dev/null 2>&1"
                    clear
                    @gum@ style --foreground 212 "Connected to $device_name"
                    sleep 2
                elif [ "$action" = "Remove device" ]; then
                    device_name=$(echo "$choice" | sed 's/^[✓✗]* *//' | sed 's/ *([^)]*).*$//')
                    clear
                    @gum@ spin --spinner dot --title "Removing $device_name" -- sh -c "@bluetoothctl@ remove '$mac' >/dev/null 2>&1"
                    clear
                    @gum@ style --foreground 212 "Device removed!"
                    sleep 2
                fi
            fi
        fi
    fi
done
