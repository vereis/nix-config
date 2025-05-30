{ self, config, system, lib, pkgs, inputs, zjstatus, username, home-manager, ... }:

{
  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    settings.auto-optimise-store = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings.experimental-features = "nix-command flakes";
    settings.download-buffer-size = 5000000000000000;
  };

  programs.zsh.enable = true;

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
    nerdfetch
    ripgrep
    tmux
    tree
    unzip
    wget
    xclip
    zip
  ];
}
