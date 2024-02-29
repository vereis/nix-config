{ config, lib, pkgs, inputs, username, ... }:

{
  imports = [ ../modules/services/gpg.nix ];

  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" "media" ];
    shell = pkgs.zsh;
  };

  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
      acpi
      bsd-finger
      cacert
      fd
      gcc
      git
      htop
      httpie
      killall
      lsof
      openssh
      openssl
      pciutils
      pfetch
      ripgrep
      tmux
      tree
      unzip
      usbutils
      wget
      xclip
      mpd
      zip
    ];

  # Allow dynamic linking of packages I build
  programs.nix-ld.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.utf8";

  nix = {
    package = pkgs.nixFlakes;
    settings.auto-optimise-store = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  security.rtkit.enable = true;
  programs.ssh.askPassword = "";

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  modules.gpg.enable = true;
  system.stateVersion = "22.11";
}
