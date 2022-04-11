{ config, lib, pkgs, ... }:

with lib;
{
  options.features.sound = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.features.sound.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;
  };
}
