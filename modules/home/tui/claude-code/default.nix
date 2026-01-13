{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.tui.claudeCode;
in
{
  options.modules.tui.claudeCode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Claude Code + deploy ~/.claude config";
    };
  };

  config = lib.mkIf (config.modules.tui.enable && cfg.enable) {
    modules.tui.extraPackages = [
      pkgs.claude-code

      # Plugin runtime deps
      # - safety-net: runs via npx (node)
      # - security-guidance: hook runs via python3
      pkgs.nodejs
      pkgs.python3

      # For claude-toggle script UI
      pkgs.gum
    ];

    # Deploy only the config pieces. Do NOT symlink the entire ~/.claude directory
    # because Claude Code writes runtime state there (projects/, ide/, plugins/, etc.).
    modules.tui.extraFiles = {
      "./.claude/CLAUDE.md" = {
        source = ./CLAUDE.md;
      };

      # Deploy both settings files for easy switching
      "./.claude/settings-claude.json" = {
        source = ./settings-claude.json;
      };

      "./.claude/settings-copilot.json" = {
        source = ./settings-copilot.json;
      };

      # Default to Claude AI mode
      "./.claude/settings.json" = {
        source = ./settings-claude.json;
        force = true;  # Allow overwriting existing files
      };

      "./.claude/skills" = {
        recursive = true;
        source = ./skills;
      };

      "./.claude/agents" = {
        recursive = true;
        source = ./agents;
      };

      "./.claude/commands" = {
        recursive = true;
        source = ./commands;
      };

      # Stable path for editor integrations.
      # We wrap the Nix-provided CLI with isolated environments per mode.
      "./.local/bin/claude" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Determine current mode by checking settings.json
          SETTINGS_FILE="$HOME/.claude/settings.json"
          if [[ -f "$SETTINGS_FILE" ]] && grep -q "ANTHROPIC_BASE_URL" "$SETTINGS_FILE" 2>/dev/null; then
            # Copilot mode - use copilot environment
            export CLAUDE_CONFIG_DIR="$HOME/.claude-copilot"
          else
            # Anthropic mode - use anthropic environment
            export CLAUDE_CONFIG_DIR="$HOME/.claude-anthropic"
          fi

          # Ensure the config directory exists
          mkdir -p "$CLAUDE_CONFIG_DIR"

          # Copy settings to the isolated environment if it doesn't exist
          if [[ ! -f "$CLAUDE_CONFIG_DIR/settings.json" ]]; then
            if [[ -f "$SETTINGS_FILE" ]]; then
              cp "$SETTINGS_FILE" "$CLAUDE_CONFIG_DIR/settings.json"
            fi

            # Copy other essential files if they exist
            for item in CLAUDE.md skills agents commands; do
              if [[ -e "$HOME/.claude/$item" ]]; then
                cp -r "$HOME/.claude/$item" "$CLAUDE_CONFIG_DIR/" 2>/dev/null || true
              fi
            done
          fi

          exec "${pkgs.claude-code}/bin/claude" --dangerously-skip-permissions "$@"
        '';
      };

      # Toggle script for switching between Claude AI and Copilot modes
      "./.local/bin/claude-toggle" = {
        executable = true;
        source = ./scripts/claude-toggle.sh;
      };
    };
  };
}
