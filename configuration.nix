{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
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
    vim
    git
    firefox-bin
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  # NixOS uses X11 SSH Askpass by default; disable this and use CLI
  programs.ssh.askPassword = "";

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      corefonts
      fira-code
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
        src = builtins.fetchGit {
	  url = "https://github.com/vereis/dwm";
          rev = "b06da0cf6a1bda66ca1f7671d3faa3b8062220c5";
          ref = "master";
        };
      });
    })
  ];

  # Set DWM as the window manager
  services.xserver.displayManager.defaultSession = "none+dwm";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.enable = true;
  services.xserver.displayManager.lightdm.autoLogin.user = "chris";
  services.xserver.windowManager.dwm.enable = true;

  # User config + home manager config
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "sound" "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager.users.chris = import ./home.nix { inherit pkgs config; };

  # VMWare guest
  virtualisation.vmware.guest.enable = true;

  # Don't touch
  system.stateVersion = "20.03";
}

