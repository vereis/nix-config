# NOTE: this file is provided as an example and may not always be 100% correct
{ config, pkgs, ... }:

{
  imports =
    [
      <home-manager/nixos>
      ./hardware-configuration.nix

      # NixOS specific modules for hardware support
      ./hardware/x11.nix
      ./hardware/base.nix
      ./hardware/sound.nix
      ./hardware/nvidia.nix
      ./hardware/keyboard.nix
      ./hardware/mx_master.nix
      ./hardware/bluetooth.nix
    ];

  networking.hostName = "tteokbokki";
  time.timeZone = "Europe/London";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  networking.networkmanager.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp10s0.useDHCP = true;
  networking.interfaces.wlp8s0.useDHCP = true;

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # ==================================================================================================
  # Start of github.com/vereis/nixos specific setup
  # ==================================================================================================

  # Enable settings for selected hardware
  hardware.x11.dpi = 125;
  hardware.x11.enable = true;

  hardware.sound.enable = true;
  hardware.nvidia.enable = true;
  hardware.bluetooth.enable = true;

  hardware.keyboard.enable = true;
  hardware.mx_master.enable = true;

  # Enable selected machine configuration
  home-manager.users.chris = import ./machines/tteokbokki.nix;

  # ==================================================================================================
  # End of github.com/vereis/nixos specific setup
  # ==================================================================================================

  system.stateVersion = "21.11";
}
