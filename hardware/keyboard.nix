{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.keyboard = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.hardware.keyboard.enable {
    services.xserver.autoRepeatDelay = 375;
    services.xserver.autoRepeatInterval = 25;
  };
}
