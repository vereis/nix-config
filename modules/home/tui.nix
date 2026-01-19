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

          # Always use blinking block cursor (in all vi modes)
          set fish_cursor_default block blink
          set fish_cursor_insert block blink
          set fish_cursor_replace_one block blink
          set fish_cursor_visual block blink

          # Tide prompt configuration
          set -g tide_aws_bg_color normal
          set -g tide_aws_color yellow
          set -g tide_aws_icon \uf270
          set -g tide_bun_bg_color normal
          set -g tide_bun_color white
          set -g tide_bun_icon \U000f0cd3
          set -g tide_character_color brgreen
          set -g tide_character_color_failure brred
          set -g tide_character_icon \u276f
          set -g tide_character_vi_icon_default \u276e
          set -g tide_character_vi_icon_replace \u25b6
          set -g tide_character_vi_icon_visual V
          set -g tide_cmd_duration_bg_color normal
          set -g tide_cmd_duration_color brblack
          set -g tide_cmd_duration_decimals 0
          set -g tide_cmd_duration_icon \x1d
          set -g tide_cmd_duration_threshold 3000
          set -g tide_context_always_display false
          set -g tide_context_bg_color normal
          set -g tide_context_color_default yellow
          set -g tide_context_color_root bryellow
          set -g tide_context_color_ssh yellow
          set -g tide_context_hostname_parts 1
          set -g tide_crystal_bg_color normal
          set -g tide_crystal_color brwhite
          set -g tide_crystal_icon \ue62f
          set -g tide_direnv_bg_color normal
          set -g tide_direnv_bg_color_denied normal
          set -g tide_direnv_color bryellow
          set -g tide_direnv_color_denied brred
          set -g tide_direnv_icon \u25bc
          set -g tide_distrobox_bg_color normal
          set -g tide_distrobox_color brmagenta
          set -g tide_distrobox_icon \U000f01a7
          set -g tide_docker_bg_color normal
          set -g tide_docker_color blue
          set -g tide_docker_default_contexts default\x1ecolima
          set -g tide_docker_icon \uf308
          set -g tide_elixir_bg_color normal
          set -g tide_elixir_color magenta
          set -g tide_elixir_icon \ue62d
          set -g tide_gcloud_bg_color normal
          set -g tide_gcloud_color blue
          set -g tide_gcloud_icon \U000f02ad
          set -g tide_git_bg_color normal
          set -g tide_git_bg_color_unstable normal
          set -g tide_git_bg_color_urgent normal
          set -g tide_git_color_branch brgreen
          set -g tide_git_color_conflicted brred
          set -g tide_git_color_dirty bryellow
          set -g tide_git_color_operation brred
          set -g tide_git_color_staged bryellow
          set -g tide_git_color_stash brgreen
          set -g tide_git_color_untracked brblue
          set -g tide_git_color_upstream brgreen
          set -g tide_git_icon \x1d
          set -g tide_git_truncation_length 24
          set -g tide_git_truncation_strategy \x1d
          set -g tide_go_bg_color normal
          set -g tide_go_color brcyan
          set -g tide_go_icon \ue627
          set -g tide_java_bg_color normal
          set -g tide_java_color yellow
          set -g tide_java_icon \ue256
          set -g tide_jobs_bg_color normal
          set -g tide_jobs_color green
          set -g tide_jobs_icon \uf013
          set -g tide_jobs_number_threshold 1000
          set -g tide_kubectl_bg_color normal
          set -g tide_kubectl_color blue
          set -g tide_kubectl_icon \U000f10fe
          set -g tide_left_prompt_frame_enabled false
          set -g tide_left_prompt_items pwd\x1egit\x1echaracter
          set -g tide_left_prompt_prefix
          set -g tide_left_prompt_separator_diff_color \x20
          set -g tide_left_prompt_separator_same_color \x20
          set -g tide_left_prompt_suffix
          set -g tide_nix_shell_bg_color normal
          set -g tide_nix_shell_color brblue
          set -g tide_nix_shell_icon \uf313
          set -g tide_node_bg_color normal
          set -g tide_node_color green
          set -g tide_node_icon \ue24f
          set -g tide_os_bg_color normal
          set -g tide_os_color brwhite
          set -g tide_os_icon \uf313
          set -g tide_php_bg_color normal
          set -g tide_php_color blue
          set -g tide_php_icon \ue608
          set -g tide_private_mode_bg_color normal
          set -g tide_private_mode_color brwhite
          set -g tide_private_mode_icon \U000f05f9
          set -g tide_prompt_add_newline_before false
          set -g tide_prompt_color_frame_and_connection brblack
          set -g tide_prompt_color_separator_same_color brblack
          set -g tide_prompt_icon_connection \x20
          set -g tide_prompt_min_cols 34
          set -g tide_prompt_pad_items false
          set -g tide_prompt_transient_enabled true
          set -g tide_pulumi_bg_color normal
          set -g tide_pulumi_color yellow
          set -g tide_pulumi_icon \uf1b2
          set -g tide_pwd_bg_color normal
          set -g tide_pwd_color_anchors brcyan
          set -g tide_pwd_color_dirs cyan
          set -g tide_pwd_color_truncated_dirs magenta
          set -g tide_pwd_icon \x1d
          set -g tide_pwd_icon_home \x1d
          set -g tide_pwd_icon_unwritable \uf023
          set -g tide_pwd_markers .bzr\x1e.citc\x1e.git\x1e.hg\x1e.node-version\x1e.python-version\x1e.ruby-version\x1e.shorten_folder_marker\x1e.svn\x1e.terraform\x1ebun.lockb\x1eCargo.toml\x1ecomposer.json\x1eCVS\x1ego.mod\x1epackage.json\x1ebuild.zig
          set -g tide_python_bg_color normal
          set -g tide_python_color cyan
          set -g tide_python_icon \U000f0320
          set -g tide_right_prompt_frame_enabled false
          set -g tide_right_prompt_items status\x1ecmd_duration\x1econtext\x1ejobs\x1edirenv\x1ebun\x1enode\x1epython\x1erustc\x1ejava\x1ephp\x1epulumi\x1eruby\x1ego\x1egcloud\x1ekubectl\x1edistrobox\x1etoolbox\x1eterraform\x1eaws\x1enix_shell\x1ecrystal\x1eelixir\x1ezig\x1etime
          set -g tide_right_prompt_prefix \x20
          set -g tide_right_prompt_separator_diff_color \x20
          set -g tide_right_prompt_separator_same_color \x20
          set -g tide_right_prompt_suffix
          set -g tide_ruby_bg_color normal
          set -g tide_ruby_color red
          set -g tide_ruby_icon \ue23e
          set -g tide_rustc_bg_color normal
          set -g tide_rustc_color red
          set -g tide_rustc_icon \ue7a8
          set -g tide_shlvl_bg_color normal
          set -g tide_shlvl_color yellow
          set -g tide_shlvl_icon \uf120
          set -g tide_shlvl_threshold 1
          set -g tide_status_bg_color normal
          set -g tide_status_bg_color_failure normal
          set -g tide_status_color green
          set -g tide_status_color_failure red
          set -g tide_status_icon \u2714
          set -g tide_status_icon_failure \u2718
          set -g tide_terraform_bg_color normal
          set -g tide_terraform_color magenta
          set -g tide_terraform_icon \U000f1062
          set -g tide_time_bg_color normal
          set -g tide_time_color brblack
          set -g tide_time_format %T
          set -g tide_toolbox_bg_color normal
          set -g tide_toolbox_color magenta
          set -g tide_toolbox_icon \ue24f
          set -g tide_vi_mode_bg_color_default normal
          set -g tide_vi_mode_bg_color_insert normal
          set -g tide_vi_mode_bg_color_replace normal
          set -g tide_vi_mode_bg_color_visual normal
          set -g tide_vi_mode_color_default white
          set -g tide_vi_mode_color_insert cyan
          set -g tide_vi_mode_color_replace green
          set -g tide_vi_mode_color_visual yellow
          set -g tide_vi_mode_icon_default D
          set -g tide_vi_mode_icon_insert I
          set -g tide_vi_mode_icon_replace R
          set -g tide_vi_mode_icon_visual V
          set -g tide_zig_bg_color normal
          set -g tide_zig_color yellow
          set -g tide_zig_icon \ue6a9
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
