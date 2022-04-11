{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.awesome = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.awesome.enable {
    home.packages = with pkgs; [ pkgs.awesome ];

    xsession.enable = true;
    xsession.windowManager.command = "${pkgs.awesome}/bin/awesome";

    services.picom.enable = true;
    services.picom.shadow = false;

    home.file.".config/awesome/rc.lua" = {
      source = ./awesome/rc.lua;
    };

    home.file.".config/awesome/themes/" = {
      source = ./awesome/themes;
    };
  };
}
