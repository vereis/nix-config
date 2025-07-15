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
        '';
      in lib.mkMerge [contentBefore contentAfter];
    };

    home.file.".p10k.zsh".source = ./tui/zsh/.p10k.zsh;

    home.file.".gitconfig" = {
      executable = false;
      text = ''
      [user]
        email = ${email}
        name = ${user}

        [color]
          ui = true

        [core]
          pager = delta

        [interactive]
          diffFilter = delta --color-only

        [delta]
          features = side-by-side line-numbers decorations
          whitespace-error-style = 22 reverse

        [delta "decorations"]
          commit-decoration-style = bold yellow box ul
          file-style = bold yellow ul
          file-decoration-style = none

        [alias]
          # GH Core aliases
          gh          = "!f() { gh $@; \n }; f"
          gist        = "!f() { gh gist $@; \n }; f"
          issue       = "!f() { gh issue $@; \n }; f"
          pr          = "!f() { gh pr $@; \n }; f"
          release     = "!f() { gh release $@; \n }; f"
          repo        = "!f() { gh repo $@; \n }; f"

          alias       = "!f() { gh alias $@; \n }; f"
          api         = "!f() { gh api $@; \n }; f"
          auth        = "!f() { gh auth $@; \n }; f"
          completion  = "!f() { gh completion $@; \n }; f"
          config      = "!f() { gh config $@; \n }; f"
          secret      = "!f() { gh secret $@; \n }; f"
          ssh-key     = "!f() { gh ssh-key $@; \n }; f"

          # Custom aliases
          push-origin = "!f() { git push origin -u $(git rev-parse --abbrev-ref HEAD) $@; \n }; f"
          rewrite     = "!f() { git rebase -i HEAD~$1; \n }; f"
          gloat       = "!f() { git shortlog -sn; \n }; f"
          root        = "!f() { git rev-parse --path-format=absolute --show-toplevel; \n }; f"
          ssh-migrate = "!f() { $HOME/.local/bin/git/ssh-migrate.sh \n }; f"
      '';
    };

    home.file.".local/bin/git/ssh-migrate.sh" = { executable = true; source = ./tui/git/migrate-ssh.sh; };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;

      extraConfig = ''
        lua require('config')
      '';
    };

    home.file.".config/nvim/lua/" = { source = ./tui/neovim/lua; recursive = true; };

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files | sort -u";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GOOGLE_CLOUD_PROJECT = secrets.gemini-cli.googleCloudProject;
    };
  };
}
