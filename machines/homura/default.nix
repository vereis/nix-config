{ pkgs, lib, username, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [ blueberry ];

  networking.hostName = "homura";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;

  services = {
    xserver.dpi = 175;
    blueman.enable = true;
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
    luks.devices."luks-9f6e9101-fdb2-4ca7-af00-c5d813e08e5e" = {
      device = "/dev/disk/by-uuid/9f6e9101-fdb2-4ca7-af00-c5d813e08e5e";
      keyFile = "/crypto_keyfile.bin";
    };
  };
}
