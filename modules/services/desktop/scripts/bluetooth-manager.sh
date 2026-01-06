#!/usr/bin/env bash

# Get list of bluetooth devices with their status
get_devices() {
    @bluetoothctl@ devices | while read -r _ mac name; do
        if @bluetoothctl@ info "$mac" | grep -q "Connected: yes"; then
            echo "🔵 $name ($mac) [CONNECTED]"
        else
            echo "⚫ $name ($mac) [DISCONNECTED]"
        fi
    done
}

# Main menu
while true; do
    choice=$(@gum@ choose --header "Bluetooth Manager" \
        "Scan for devices" \
        "Pair new device" \
        $(get_devices) \
        "Exit")
    
    if [ "$choice" = "Exit" ]; then
        break
    elif [ "$choice" = "Scan for devices" ]; then
        @gum@ spin --spinner dot --title "Scanning for devices..." -- sleep 5 &
        @bluetoothctl@ scan on &
        SCAN_PID=$!
        sleep 5
        kill $SCAN_PID 2>/dev/null
        @bluetoothctl@ scan off
    elif [ "$choice" = "Pair new device" ]; then
        # Show discovered devices
        devices=$(@bluetoothctl@ devices | @gum@ choose --header "Select device to pair")
        if [ -n "$devices" ]; then
            mac=$(echo "$devices" | awk '{print $2}')
            @gum@ spin --spinner dot --title "Pairing with device..." -- @bluetoothctl@ pair "$mac"
            @bluetoothctl@ trust "$mac"
            @gum@ style --foreground 212 "Device paired successfully!"
            sleep 1
        fi
    else
        # Extract MAC address from selection
        mac=$(echo "$choice" | grep -oP '\([0-9A-F:]+\)' | tr -d '()')
        
        if echo "$choice" | grep -q "CONNECTED"; then
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1)" \
                "Disconnect" \
                "Back")
            
            if [ "$action" = "Disconnect" ]; then
                @bluetoothctl@ disconnect "$mac"
                @gum@ style --foreground 212 "Device disconnected!"
                sleep 1
            fi
        else
            action=$(@gum@ choose --header "Device: $(echo "$choice" | cut -d'(' -f1)" \
                "Connect" \
                "Remove device" \
                "Back")
            
            if [ "$action" = "Connect" ]; then
                @gum@ spin --spinner dot --title "Connecting..." -- @bluetoothctl@ connect "$mac"
                @gum@ style --foreground 212 "Device connected!"
                sleep 1
            elif [ "$action" = "Remove device" ]; then
                @bluetoothctl@ remove "$mac"
                @gum@ style --foreground 212 "Device removed!"
                sleep 1
            fi
        fi
    fi
done
