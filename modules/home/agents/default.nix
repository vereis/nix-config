{
  config,
  lib,
  pkgs,
  ...
}:

with lib; {
  options.modules.agents = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AI agent configuration system";
    };

    # Tool-specific enables
    claude-code = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Deploy Claude Code configuration";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Additional tool-specific config overrides for Claude Code settings.json";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.claude-code or null;
        description = "Claude Code package to install";
      };
    };

    opencode = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Deploy OpenCode configuration";
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Additional tool-specific config overrides for OpenCode opencode.json";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.opencode or null;
        description = "OpenCode package to install";
      };
    };

    # Shared definitions (read-only, computed from definitions/*.nix)
    skills = mkOption {
      type = types.attrsOf types.attrs;
      readOnly = true;
      default = {};
      description = "Structured skill definitions";
    };

    commands = mkOption {
      type = types.attrsOf types.attrs;
      readOnly = true;
      default = {};
      description = "Structured command definitions";
    };

    agents = mkOption {
      type = types.attrsOf types.attrs;
      readOnly = true;
      default = {};
      description = "Structured agent definitions";
    };
  };

  config = mkIf config.modules.agents.enable (mkMerge [
    # Load generator functions and definitions
    (let
      generators = import ./lib/generators.nix { inherit lib; };
    in {
      # Expose skills definitions
      modules.agents.skills = import ./definitions/skills.nix {
        inherit lib;
        inherit (generators) mkSkill;
      };

      # Expose commands definitions
      modules.agents.commands = import ./definitions/commands.nix {
        inherit lib;
        inherit (generators) mkCommand;
      };
    })

    # Assertions
    {
      assertions = [
        {
          assertion = config.modules.agents.claude-code.enable -> config.modules.agents.claude-code.package != null;
          message = "Claude Code package must be set when claude-code is enabled";
        }
        {
          assertion = config.modules.agents.opencode.enable -> config.modules.agents.opencode.package != null;
          message = "OpenCode package must be set when opencode is enabled";
        }
      ];
    }

    # TODO: Add deployment logic in Commit 8
  ]);
}
