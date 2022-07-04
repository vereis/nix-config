{ config, lib, pkgs, ... }:

with lib;
{
  options.features.steam = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.features.steam.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
  };
}
