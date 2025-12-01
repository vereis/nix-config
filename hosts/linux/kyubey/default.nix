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
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "storage" ];
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
  ];

  networking = {
    hostId = "8453be09";
    hostName = "kyubey";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        24800
        51413
      ];
      allowedUDPPorts = [
        22
        80
        443
        24800
        51413
      ];
    };
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };
    getty.autologinUser = username;
    xserver = {
      dpi = 100;
      videoDrivers = [ "nvidia" ];
    };
    desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.desktop.session]
      idle-delay=uint32 0
    '';
  };

  systemd = {
    targets = {
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
    services.systemd-suspend.enable = false;
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';
  };

  hardware.nvidia.open = false;
}
