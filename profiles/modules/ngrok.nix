{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.ngrok = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.ngrok.enable {
    home.packages = [pkgs.ngrok];
  };
}

