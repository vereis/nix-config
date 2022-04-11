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

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files | sort -u";
    };
  };
}
