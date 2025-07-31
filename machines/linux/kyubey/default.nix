{ pkgs, lib, username, ... }:

{
  imports = [ ./hardware-configuration.nix ./services.nix ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  environment.systemPackages = with pkgs; [ vulkan-loader vulkan-tools ];

  networking.hostId = "8453be09";
  networking.hostName = "kyubey";
  networking.networkmanager.enable = true;

  services.getty.autologinUser = username;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  services.xserver.dpi = 100;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
}
