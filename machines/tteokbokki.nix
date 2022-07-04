# Nixos style configuration.
{ config, pkgs, ... }:

{
  imports =
    [
      <home-manager/nixos>

      ./base.nix
      ./features/base.nix
      ./features/gnome.nix
      ./features/sound.nix
      ./features/steam.nix
      ./hardware/nvidia.nix

      /etc/nixos/hardware-configuration.nix
    ];

  machine.turbo = false;
  machine.hostName = "tteokbokki";

  features.gnome.enable = true;
  features.steam.enable = true;
  features.sound.enable = true;
  hardware.nvidia.enable = true;

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  networking.firewall.enable = false;
  # networking.firewall.trustedInterfaces = [ "docker0" ];
  home-manager.users.chris = import ../profiles/chris.nix;
  system.stateVersion = "21.11";
}
