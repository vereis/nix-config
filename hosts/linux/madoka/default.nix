{
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    hostName = "madoka";
    networkmanager.enable = true;
  };

  services = {
    getty.autologinUser = username;
    printing.enable = true;
  };
}
