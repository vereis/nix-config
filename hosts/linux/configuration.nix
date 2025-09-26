{
  username,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:

{
  programs.zsh.enable = lib.mkForce true;

  users.users.${username} = {
    isNormalUser = true;
    name = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "media"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings.experimental-features = "nix-command flakes";
    settings.download-buffer-size = 5000000000000000;
  };

  programs.ssh.askPassword = "";
  services.openssh.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  system.stateVersion = "24.05";
}
