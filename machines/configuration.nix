{ self, config, system, lib, pkgs, inputs, zjstatus, username, home-manager, ... }:

{
  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    settings.auto-optimise-store = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings.experimental-features = "nix-command flakes";
  };

  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    cacert
    fd
    gcc
    git
    htop
    httpie
    killall
    lsof
    nixpkgs-fmt
    nixpkgs-lint
    openssh
    openssl
    pciutils
    pfetch
    ripgrep
    tmux
    tree
    unzip
    wget
    xclip
    zip
  ];
}
