{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.synergy = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.synergy.enable {
    home.packages = [ pkgs.synergy ];
  };
}

