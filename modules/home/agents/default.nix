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

    # Shared definitions (computed from definitions/*.nix)
    skills = mkOption {
      type = types.attrsOf types.attrs;
      internal = true;
      default = {};
      description = "Structured skill definitions";
    };

    commands = mkOption {
      type = types.attrsOf types.attrs;
      internal = true;
      default = {};
      description = "Structured command definitions";
    };

    agents = mkOption {
      type = types.attrsOf types.attrs;
      internal = true;
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

      # Expose agents definitions
      modules.agents.agents = import ./definitions/agents.nix {
        inherit lib;
        inherit (generators) mkAgent;
      };
    })

    # Claude Code deployment
    (mkIf config.modules.agents.claude-code.enable (
      let
        generators = import ./lib/generators.nix { inherit lib; };

        # Helper to generate skill directory with SKILL.md and supporting files
        mkSkillDir = name: skill:
          pkgs.runCommand "skill-${name}" {} ''
            mkdir -p $out/${name}
            cat > $out/${name}/SKILL.md <<'NIXEOF'
            ${skill.toClaude}
            NIXEOF
            ${concatMapStringsSep "\n" (file: ''
              cat > $out/${name}/${file.name} <<'NIXEOF'
              ${file.content}
              NIXEOF
            '') skill.supportingFiles}
          '';

        # Generate all skill directories
        skillDirs = mapAttrs mkSkillDir config.modules.agents.skills;

        # Combine all skills into one directory
        allSkills = pkgs.runCommand "claude-skills" {} ''
          mkdir -p $out
          ${concatStringsSep "\n" (mapAttrsToList (name: dir: "ln -s ${dir}/${name} $out/${name}") skillDirs)}
        '';

        # Helper to generate command markdown
        mkCommandFile = name: command:
          pkgs.writeText "${name}.md" command.toClaude;

        # Generate all commands
        commandFiles = mapAttrs mkCommandFile config.modules.agents.commands;

        # Helper to generate agent markdown
        mkAgentFile = name: agent:
          pkgs.writeText "${name}.md" agent.toClaude;

        # Generate all agents
        agentFiles = mapAttrs mkAgentFile config.modules.agents.agents;

        # Settings merged with extraConfig
        settings =
          (builtins.fromJSON (builtins.readFile ./settings/claude-code.json))
          // config.modules.agents.claude-code.extraConfig;
      in
      {
        # Install Claude Code package
        home.packages = [ config.modules.agents.claude-code.package ];

        # Deploy configuration files
        home.file = {
          # Personality
          ".claude/CLAUDE.md".source = ./definitions/personality.md;

          # Settings
          ".claude/settings.json".text = builtins.toJSON settings;

          # Skills (generated, with subdirectories)
          ".claude/skills".source = allSkills;

          # Commands (generated)
        } // (mapAttrs' (name: file:
          nameValuePair ".claude/commands/${name}.md" { source = file; }
        ) commandFiles)

        # Agents (generated)
        // (mapAttrs' (name: file:
          nameValuePair ".claude/agents/${name}.md" { source = file; }
        ) agentFiles)

        # Wrapper script
        // {
          ".local/bin/claude" = {
            executable = true;
            text = ''
              #!/bin/sh
              exec ${config.modules.agents.claude-code.package}/bin/claude-code --dangerously-skip-permissions "$@"
            '';
          };
        };
      }
    ))

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
  ]);
}
