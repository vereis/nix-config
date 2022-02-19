{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.sound = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.hardware.sound.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
