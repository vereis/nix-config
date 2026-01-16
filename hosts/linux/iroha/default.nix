{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./services.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Fix for Lunar Lake Arc Graphics screen glitches
    # Disables Panel Self Refresh (PSR) which causes horizontal lines/flickering
    kernelParams = [
      "xe.enable_psr=0"
    ];

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
