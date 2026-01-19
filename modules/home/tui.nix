{
  config,
  lib,
  pkgs,
  user,
  email,
  secrets,
  ...
}:

with lib;
{
  imports = [
    ./tui/zellij.nix
    ./tui/claude-code
  ];

  options.modules.tui = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install for TUI applications.";
    };
    extraFiles = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Extra files to create in the home directory. Accepts any valid home-manager file attributes.";
    };
    extraSessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra session variables to set. Use this for machine-specific secrets and configuration.";
    };
  };

  config = mkIf config.modules.tui.enable {
    home = {
      packages =
        with pkgs;
        [
          aria2
          btop
          cacert
          cargo
          delta
          fd
          git-absorb
          ffmpeg
          gcc
          gh
          git
          httpie
          jq
          killall
          lsof
          nerdfetch
          openssh
          openssl
          pciutils
          ripgrep
          rsync
          tree
          unzip
          wget
          zip
          gnumake
          git-crypt
          lf
          socat
          # Dependencies for lf previewer
          poppler-utils # provides pdftotext
          highlight
          unrar
          p7zip # provides 7z
        ]
        ++ config.modules.tui.extraPackages;

      file = lib.mkMerge [
        {
          ".local/bin/git/ssh-migrate.sh" = {
            executable = true;
            source = ./tui/git/migrate-ssh.sh;
          };
          ".local/bin/npiperelay.exe" = {
            executable = true;
            source = ../../bin/npiperelay.exe;
          };
          ".config/nvim/lua/" = {
            recursive = true;
            source = ./tui/neovim/lua;
          };
          ".gitconfig" = {
            executable = false;
            text = builtins.replaceStrings [ "EMAIL_PLACEHOLDER" "USER_PLACEHOLDER" ] [ email user ] (
              builtins.readFile ./tui/git/.gitconfig
            );
          };
          ".gitconfig-vetspire" = {
            executable = false;
            text = builtins.replaceStrings [ "VETSPIRE_EMAIL_PLACEHOLDER" ] [ secrets.vetspire.gitEmail ] (
              builtins.readFile ./tui/git/.gitconfig-vetspire
            );
          };
          ".gitignore_global" = {
            executable = false;
            source = ./tui/git/.gitignore_global;
          };
        }
        config.modules.tui.extraFiles
      ];

      sessionVariables = {
        FZF_DEFAULT_COMMAND = "rg --files";
        EDITOR = "nvim";
        VISUAL = "nvim";
      }
      // config.modules.tui.extraSessionVariables;
    };

    programs = {
      atuin = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          auto_sync = false; # Start with local-only
          search_mode = "fuzzy";
          filter_mode = "global";
          style = "compact";
          inline_height = 20;
          show_preview = true;
        };
      };

      direnv = {
        enable = true;
        enableBashIntegration = true;
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd cd" # Use 'cd' instead of 'z'
        ];
      };

      fish = {
        enable = true;

        interactiveShellInit = ''
          # Set vi key bindings
          fish_vi_key_bindings

          # Ctrl-A/E for line navigation
          bind -M insert \ca beginning-of-line
          bind -M insert \ce end-of-line

          # Vi mode: 'v' to edit command in editor
          bind -M default v edit_command_buffer

          # No greeting
          set fish_greeting
        '';

        shellAliases = {
          vim = "nvim";
        };

        plugins = [
          {
            name = "tide";
            inherit (pkgs.fishPlugins.tide) src;
          }
        ];
      };

      neovim = {
        enable = true;

        withNodeJs = true;
        withPython3 = true;

        extraConfig = ''
          lua require('config')
        '';
      };

      lf = {
        enable = true;
        previewer.source = pkgs.writeShellScriptBin "lf-preview" ''
          #!/bin/sh

          case "$1" in
            *.tar*) tar tf "$1";;
            *.zip) unzip -l "$1";;
            *.rar) unrar l "$1";;
            *.7z) 7z l "$1";;
            *.pdf) pdftotext "$1" -;;
            *) highlight -O ansi "$1" || cat "$1";;
          esac
        '';
        settings = {
          cursorpreviewfmt = "";
        };
      };
    };
  };
}
