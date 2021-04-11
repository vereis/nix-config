{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.fzf = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.fzf.enable {
    home.packages = [
      pkgs.fzf
    ];

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = config.modules.zsh.enable;

    programs.zsh.initExtra = mkIf config.modules.zsh.enable ''
      # == Start modules/fzf.nix ==
      export FZF_DEFAULT_COMMAND="rg --files | sort -u"
      # == End modules/fzf.nix ==
    '';
  };
}
