{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.vetspire = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.vetspire.enable {
    programs.zsh = {
      shellAliases = {
        vetspire = "nohup ~/.config/zellij/scripts/vetspire";
      };
    };

    home.packages = with pkgs; [ slack teams dbeaver ngrok synergy ];
  };
}
