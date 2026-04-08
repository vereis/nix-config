{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
    ../../../modules/hardware/dell/xps/13-9350
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    hostName = "iroha";
    networkmanager.enable = true;
  };

  services = {
    printing.enable = true;
  };
}
