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
    modules.tui.extraPackages = [ pkgs.claude-code ];

    # Deploy only the config pieces. Do NOT symlink the entire ~/.claude directory
    # because Claude Code writes runtime state there (projects/, ide/, plugins/, etc.).
    modules.tui.extraFiles = {
      "./.claude/CLAUDE.md" = {
        source = ./CLAUDE.md;
      };

      "./.claude/settings.json" = {
        source = ./settings.json;
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
    };
  };
}
