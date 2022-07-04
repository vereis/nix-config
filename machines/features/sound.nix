{ config, lib, pkgs, ... }:

with lib;
{
  options.features.sound = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.features.sound.enable {
    security.rtkit.enable = true;
    services.pipewire.enable = true;

    services.pipewire.alsa.enable = true;
    services.pipewire.pulse.enable = true;

    services.pipewire.alsa.support32Bit = true;
    hardware.pulseaudio.enable = false;
    # hardware.pulseaudio.support32Bit = true; 
    # hardware.pulseaudio.extraConfig = "unload-module module-suspend-on-idle";
    # hardware.pulseaudio.package = pkgs.pulseaudioFull;

    # nixpkgs.config.pulseaudio = true;
  };
}
