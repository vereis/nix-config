{ config, pkgs, ... }:

{
  imports =
    [
      (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

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
    glxinfo
    lshw
    pciutils
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  programs.ssh = {
    startAgent = true;

    # NixOS uses X11 SSH Askpass by default; disable this and use CLI
    askPassword = "";
  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      corefonts
      fira-code
      font-awesome-ttf
      unifont
    ];

   # Think this is an updated `infinality` patch
   fontconfig.penultimate.enable = true; 
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Override nixos DWM with personal build
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs(_: {
        src = builtins.fetchGit {
	  url = "https://github.com/vereis/dwm";
          rev = "101300dc26467cb9c474dde946655ad68528ae35";
          ref = "master";
        };
      });
    })
  ];

  # X Server settings
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";

    displayManager = {
      defaultSession = "none+dwm";
      lightdm.enable = true;
      lightdm.autoLogin.enable = true;
      lightdm.autoLogin.user = "chris";
    };

    windowManager.dwm.enable = true;

    exportConfiguration = true;
    config = ''
      Section "InputClass"
        Identifier "My Mouse"
        MatchIsPointer "on"

        Option "AccelerationNumerator" "1"
        Option "AccelerationDenominator" "1"
        Option "AccelerationThreshold" "0"

        Option "ConstantDeceleration" "7"
        Option "AdaptiveDeceleration" "7"
      EndSection
    '';

    enableCtrlAltBackspace = true;
  };

  # Use AMD GPU from latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable docker
  virtualisation = {
    docker.enable = true;
  };

  # Enable third party packages
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # User config + home manager config
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "sound" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager.users.chris = import ./home.nix { inherit pkgs config; };
  services.lorri.enable = true;

  # Don't touch
  system.stateVersion = "20.03";
}

