{ config, lib, pkgs, ... }:

with lib;
{
  options.features.gnome = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.features.gnome.enable {
    services.xserver.enable = true;

    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Only install the bare minimum number of packages
    environment.gnome.excludePackages = [
      pkgs.baobab
      pkgs.yelp
      pkgs.simple-scan
      pkgs.gnome-connections
      pkgs.gnome.file-roller
      pkgs.gnome.gnome-calculator
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-usage
      pkgs.gnome.gnome-font-viewer
      pkgs.gnome.gnome-system-monitor
      pkgs.gnome.gnome-disk-utility
      pkgs.gnome.gnome-maps
      pkgs.gnome.cheese
      pkgs.gnome-photos
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-terminal
      pkgs.gnome.gedit
      pkgs.epiphany
      pkgs.evince
      pkgs.gnome.gnome-characters
      pkgs.gnome.totem
      pkgs.gnome.tali
      pkgs.gnome.iagno
      pkgs.gnome.hitori
      pkgs.gnome.atomix
      pkgs.gnome-tour
      pkgs.gnome.geary
    ];
  };
}
