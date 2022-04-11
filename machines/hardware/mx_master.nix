{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.mx_master = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.hardware.mx_master.enable {
    services.xserver.libinput.enable = true;
    services.xserver.libinput.mouse = {
      accelProfile = "flat";
      accelSpeed = "-0.3";
    };
  };
}
