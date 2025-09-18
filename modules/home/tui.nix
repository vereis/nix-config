{ config, lib, pkgs, user, email, secrets, ... }:

with lib;
{
  imports = [ ./tui/zellij.nix ];

  options.modules.tui = {
    enable = mkOption { type = types.bool; default = false; };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install for TUI applications.";
    };
    extraFiles = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      description = "Extra files to create in the home directory. Accepts any valid home-manager file attributes.";
    };
    extraSessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra session variables to set. Use this for machine-specific secrets and configuration.";
    };
  };

  config = mkIf config.modules.tui.enable {
    home.packages = with pkgs; [
      btop
      cacert
      cargo
      delta
      fd
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
      zsh
      gnumake
      git-crypt
      lf
      socat
      # Dependencies for lf previewer
      poppler_utils  # provides pdftotext
      highlight
      unrar
      p7zip         # provides 7z
    ] ++ config.modules.tui.extraPackages;
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    programs.zsh = {
      enable = true;

      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      prezto = {
        enable = true;
        editor.keymap = "vi";
        caseSensitive = false;
        prompt.theme = "powerlevel10k";

        utility.safeOps = true;

        terminal = {
          autoTitle = true;
          multiplexerTitleFormat = "%s";
          tabTitleFormat = "%s";
          windowTitleFormat = "%s";
        };

        syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "cursor" "root" ];
      };

      initContent = let
        contentBefore = lib.mkBefore ''
          export TERM=xterm-256color
          if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi
        '';

        contentAfter = lib.mkAfter ''
          # Normal mode 'v' to edit command in vim
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey -M vicmd v edit-command-line

          # Vim mode doesn't let you use ctrl-a/e to go to the beginning/end of the line
          bindkey "^A" vi-beginning-of-line
          bindkey "^E" vi-end-of-line

          source $HOME/.p10k.zsh

          # If in WSL, when launching vim, set up `npiperelay` to forward stdin/stdout to Windows
          vim() {
            if [ -n "$WSL_DISTRO_NAME" ]; then
              if ! pidof socat > /dev/null 2>&1; then
                  [ -e /tmp/discord-ipc-0 ] && rm -f /tmp/discord-ipc-0
                  socat UNIX-LISTEN:/tmp/discord-ipc-0,fork \
                      EXEC:"npiperelay.exe //./pipe/discord-ipc-0" 2>/dev/null &
              fi
            fi

            if [ $# -eq 0 ]; then
              command nvim
            else
              command nvim "$@"
            fi
          }
        '';
      in lib.mkMerge [contentBefore contentAfter];
    };

    home.file = lib.mkMerge [
      {
        ".p10k.zsh" = { executable = true; source = ./tui/zsh/.p10k.zsh;  };
        ".local/bin/git/ssh-migrate.sh" = { executable = true; source = ./tui/git/migrate-ssh.sh; };
        ".local/bin/npiperelay.exe" = { executable = true; source = ../../bin/npiperelay.exe; };
        ".config/nvim/lua/" = { recursive = true; source= ./tui/neovim/lua; };
        ".gitconfig" = { 
          executable = false; 
          text = builtins.replaceStrings 
            ["EMAIL_PLACEHOLDER" "USER_PLACEHOLDER"] 
            [email user] 
            (builtins.readFile ./tui/git/.gitconfig);
        };
      }
      config.modules.tui.extraFiles
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    programs.neovim = {
      enable = true;

      withNodeJs = true;
      withPython3 = true;

      extraConfig = ''
        lua require('config')
      '';
    };

    programs.lf = {
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

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files";
      EDITOR = "nvim";
      VISUAL = "nvim";
    } // config.modules.tui.extraSessionVariables;
  };
}
