{ pkgs, lib, username, config, ... }:

{
  imports = [ ./hardware-configuration.nix ./services.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    open = true; # Use open source kernel module
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Needed for `../../../modules/home/gui.nix`
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker Support
  users.users.${username}.extraGroups = [ "docker" ];
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  system.stateVersion = lib.mkForce "24.05";
}
