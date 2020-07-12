{ config, pkgs, ... }:

{
  # All my configs rely on home-manager
  # TODO: move this into ../modules/home-manager.nix
  imports = [
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
  ];

  # Locale related settings; override in other modules
  # if neccessary.
  nixpkgs.config.allowUnfree = true;
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/London";
  
  # Sane defaults
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
      corefonts
      fira-code
      font-awesome-ttf
      unifont
    ];

  fonts.fontconfig.penultimate.enable = true;

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.enableCtrlAltBackspace = true;

  # Standard environment
  environment.systemPackages = with pkgs; [
    wget
    unzip
    unrar
    htop
    curl
    vim
    dmenu
    git
    glxinfo
    lshw
    pciutils
  ];

  # Disable X11 SSH askpass -- I prefer the CLI
  programs.ssh.askPassword = "";

  # Quality of Life
  programs.ssh.startAgent = true;
}
