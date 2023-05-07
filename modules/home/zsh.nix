{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.zsh = {
    enable        = mkOption { type = types.bool; default = false; };
    enablePortals = mkOption { type = types.bool; default = true; };
    portalPath    = mkOption { type = types.str;  default = "$HOME/.portals"; };
  };

  config = mkIf config.modules.zsh.enable {
    home.packages = with pkgs; [ zsh ];
    home.file.".p10k.zsh".source = ./zsh/.p10k.zsh;

    programs.zsh = {
      enable = true;

      autocd = true;
      enableCompletion = true;
      enableAutosuggestions = true;

      prezto = {
        enable = true;
        prompt.theme = "powerlevel10k";
        editor.keymap = "vi";
        syntaxHighlighting.highlighters = [ "main" "brackets" "pattern" "line" "cursor" "root" ];
        terminal = {
          autoTitle = true;
          multiplexerTitleFormat = "%s";
          tabTitleFormat = "%s";
          windowTitleFormat = "%s";
        };
        utility.safeOps = true;
      };

      cdpath = mkIf config.modules.zsh.enablePortals [ config.modules.zsh.portalPath ];

      initExtraFirst = ''
        if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi
      '';

      initExtra = (mkMerge [
        ''
          # TODO: this isn't neccessarily wsl related anymore -- revise naming
          # TODO: use PM2 instead of ad-hoc shellscripts
          # Execute any custom wsl-service scripts
          for file in /etc/profile.d/**/*.wsl-service(DN); . $file
          for file in $HOME/.nix-profile/etc/profile.d/**/*.wsl-service(DN); . $file
        ''
        (mkIf config.modules.zsh.enablePortals ''
          mkdir -p ${ config.modules.zsh.portalPath }
          zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories path-directories'

          zstyle ':completion:*' group-name ${"''"}
          zstyle ':completion:*:descriptions' format %B%U%d:%u%b

          source $HOME/.p10k.zsh
        '')
        ''
        # Normal mode 'v' to edit command in vim
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey -M vicmd v edit-command-line
        ''
      ]);
    };

  };
}
