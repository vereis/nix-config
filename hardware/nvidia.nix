{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.nvidia = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.hardware.nvidia.enable {
    nixpkgs.config.allowUnfree = true;
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
