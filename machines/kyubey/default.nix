{ pkgs, lib, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [ vulkan-loader vulkan-tools vulkan-validation-layers ];

  networking.hostName = "kyubey";
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  services.xserver.dpi = 100;
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
}
