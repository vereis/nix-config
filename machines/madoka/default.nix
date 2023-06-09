{ pkgs, lib, username, ... }:

{
  imports = [ ./hardware-configuration.nix ./services.nix ./hardware.nix ];

  environment.systemPackages = with pkgs; [ blueberry vulkan-loader vulkan-tools vulkan-validation-layers ];

  networking.hostName = "madoka";
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];

  programs.steam.enable = true;
  hardware.bluetooth.enable = true;
  hardware.steam-hardware.enable = true;

  services = {
    blueman.enable = true;
    xserver = {
      dpi = 100;
      videoDrivers = [ "nvidia" ];
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  # The following attribute set sets up drive encryption.
  # If re-installing or moving on a new machine, look into doing this by label
  # or simply change the UUIDs.
  boot.initrd = {
    secrets."/crypto_keyfile.bin" = null;
    luks.devices."luks-de88b439-9b0e-416b-b22b-b47115968fce" = {
      device = "/dev/disk/by-uuid/de88b439-9b0e-416b-b22b-b47115968fce";
      keyFile = "/crypto_keyfile.bin";
    };
  };

  # Disable sleep
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
