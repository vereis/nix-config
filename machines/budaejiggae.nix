# Nixos style configuration.
{ config, pkgs, ... }:

{
  imports =
    [
      <home-manager/nixos>

      ./base.nix
      ./features/gnome.nix
      ./features/sound.nix

      /etc/nixos/hardware-configuration.nix
    ];

  machine.hostName = "budaejiggae";
  features.gnome.enable = true;
  features.sound.enable = true;

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager.users.chris = import ../profiles/chris.nix;
  system.stateVersion = "21.11";
}
