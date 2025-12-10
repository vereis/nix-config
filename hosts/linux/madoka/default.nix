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

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
  ];

  networking = {
    hostName = "madoka";
    networkmanager.enable = true;
  };

  services = {
    getty.autologinUser = username;
    printing = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = {
        enable = true;
      };
    };
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager.gdm = {
      enable = true;
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.desktop.session]
        idle-delay=uint32 0
      '';
    };
  };

  programs.firefox.enable = false;

  hardware.nvidia.open = false;
}
