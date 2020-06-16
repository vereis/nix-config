{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "tteokbokki";

  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    wget
    unzip
    unrar
    htop
    curl
    dmenu
    neovim
    konsole
    git
    firefox-bin
    home-manager
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      corefonts
      fira
      fira-code-symbols
      font-awesome-ttf
      unifont
    ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Override nixos DWM with personal build
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs(_: {
        src = builtins.fetchGit https://github.com/vereis/dwm;
      });
    })
  ];

  # Set DWM as the window manager
  services.xserver.displayManager.defaultSession = "none+dwm";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = "chris";
  services.xserver.windowManager.dwm.enable = true;

  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "sound" "wheel" ];
    shell = pkgs.zsh;
  };

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.03";
}

