#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
CLAUDE_SETTINGS="$CLAUDE_DIR/settings-claude.json"
COPILOT_SETTINGS="$CLAUDE_DIR/settings-copilot.json"
LOG_FILE="$HOME/.cache/copilot-api.log"

get_current_mode() {
  if [[ ! -f $SETTINGS_FILE ]]; then echo "unknown"; return; fi
  if grep -q "ANTHROPIC_BASE_URL" "$SETTINGS_FILE" 2>/dev/null; then
    echo "copilot"
  else
    echo "claude"
  fi
}

is_copilot_running() {
  pgrep -f "copilot-api" >/dev/null 2>&1
}

start_copilot() {
  if is_copilot_running; then
    gum log --structured --level warn "copilot-api is already running"
    return 0
  fi

  gum log --structured --level info "Starting copilot-api proxy..."
  mkdir -p "$(dirname "$LOG_FILE")"

  # Clear old logs so we don't trigger on old "Listening" messages
  : > "$LOG_FILE"

  gum log --structured --level info "Checking authentication / Starting service..."

  # Start the process
  nohup npx -y copilot-api start --host 127.0.0.1 --port 4141 > "$LOG_FILE" 2>&1 &
  local PID=$!

  gum style --foreground 212 --margin "1" "Following logs (Ctrl+C to cancel manually)..."

  # Follow logs in background
  tail -f "$LOG_FILE" &
  local TAIL_PID=$!

  # Function to cleanup tail if user hits Ctrl+C
  cleanup() {
    kill $TAIL_PID 2>/dev/null || true
  }
  trap cleanup SIGINT

  # Loop until service is ready
  while true; do
    # Check for the actual success message in your output
    if grep -q "Listening on:" "$LOG_FILE"; then
       echo ""
       gum log --structured --level info "Server detected and listening!"
       kill $TAIL_PID 2>/dev/null
       break
    fi

    # If the main process died, stop waiting
    if ! kill -0 $PID 2>/dev/null; then
       echo ""
       gum log --structured --level error "Process exited unexpectedly."
       kill $TAIL_PID 2>/dev/null
       break
    fi
    sleep 1
  done

  # Restore default SIGINT behavior
  trap - SIGINT

  if is_copilot_running; then
    gum log --structured --level info "copilot-api is now running in background"
  else
    gum log --structured --level error "Failed to start. Check $LOG_FILE"
  fi
}

stop_copilot() {
  if ! is_copilot_running; then
    gum log --structured --level warn "copilot-api is not running"
    return 0
  fi

  gum log --structured --level info "Stopping copilot-api..."
  pkill -f "copilot-api" || true
  sleep 1
  gum log --structured --level info "Stopped"
}

switch_to_claude() {
  gum log --structured --level info "Switching to Claude AI mode..."

  if [[ ! -f $CLAUDE_SETTINGS ]]; then
    gum log --structured --level error "Missing $CLAUDE_SETTINGS"
    exit 1
  fi

  rm -f "$SETTINGS_FILE"
  cp "$CLAUDE_SETTINGS" "$SETTINGS_FILE"

  if is_copilot_running; then
    stop_copilot
  fi

  gum log --structured --level info "Switched to Claude AI"
}

switch_to_copilot() {
  gum log --structured --level info "Switching to GitHub Copilot mode..."

  if [[ ! -f $COPILOT_SETTINGS ]]; then
    gum log --structured --level error "Missing $COPILOT_SETTINGS"
    exit 1
  fi

  rm -f "$SETTINGS_FILE"
  cp "$COPILOT_SETTINGS" "$SETTINGS_FILE"

  gum log --structured --level info "Switched to GitHub Copilot"
  start_copilot
}

show_status() {
  local mode=$(get_current_mode)
  local provider_display
  local proxy_display

  case "$mode" in
    claude)
      provider_display=$(gum style --foreground 75 "Anthropic")
      ;;
    copilot)
      provider_display=$(gum style --foreground 212 "Copilot")
      ;;
    unknown)
      provider_display=$(gum style --foreground 214 "Unknown")
      ;;
  esac

  if is_copilot_running; then
    local pids=$(pgrep -f copilot-api | tr '\n' ' ' | sed 's/ $//')
    proxy_display=$(gum style --foreground 2 "$pids")
  else
    proxy_display=$(gum style --foreground 8 "none")
  fi

  gum style --bold "Claude Code Proxy"
  gum style "  Provider: $provider_display"
  gum style "  Proxy: $proxy_display"
}

show_menu() {
  show_status
  echo ""

  # Enable fuzzy search with limited height
  local choice=$(echo -e "Switch to Anthropic\nSwitch to Copilot\nDebug\nQuit" | gum filter --height 6 --placeholder "Choose action...")

  # Handle ESC key (empty choice) or Q
  if [[ -z "$choice" || "$choice" == "Quit" ]]; then
    gum style --foreground 212 "Goodbye!"
    exit 0
  fi

  case "$choice" in
    "Switch to Anthropic")
      switch_to_claude
      ;;
    "Switch to Copilot")
      switch_to_copilot
      ;;
    "Debug")
      show_debug_menu
      ;;
  esac
}

show_debug_menu() {
  show_status
  echo ""
  gum style --bold "Debug Menu"

  local choice=$(echo -e "Start copilot-api proxy\nStop copilot-api proxy\nShow logs\nBack" | gum filter --height 6 --placeholder "Choose debug action...")

  # Handle ESC key (empty choice)
  if [[ -z "$choice" ]]; then
    return
  fi

  case "$choice" in
    "Start copilot-api proxy")
      start_copilot
      ;;
    "Stop copilot-api proxy")
      stop_copilot
      ;;
    "Show logs")
      if [[ -f "$LOG_FILE" ]]; then
        gum style --foreground 214 "Recent logs:"
        tail -20 "$LOG_FILE"
      else
        gum log --structured --level warn "No log file found"
      fi
      ;;
    "Back")
      return
      ;;
  esac
}

main() {
  case "${1:-menu}" in
    claude)
      switch_to_claude
      ;;
    copilot)
      switch_to_copilot
      ;;
    start)
      start_copilot
      ;;
    stop)
      stop_copilot
      ;;
    status)
      show_status
      ;;
    menu)
      while true; do
        show_menu
        echo ""
      done
      ;;
    *)
      gum style --bold --foreground 212 "Claude Toggle"
      echo ""
      gum style --italic "Usage: $0 {claude|copilot|start|stop|status|menu}"
      echo ""
      gum style "Commands:"
      gum style "  claude    - Switch to Claude AI mode"
      gum style "  copilot   - Switch to GitHub Copilot mode"
      gum style "  start     - Start copilot-api proxy"
      gum style "  stop      - Stop copilot-api proxy"
      gum style "  status    - Show current mode and service status"
      gum style "  menu      - Show interactive menu (default)"
      exit 1
      ;;
  esac
}

main "$@"

main "$@"
