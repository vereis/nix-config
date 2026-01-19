{
  username,
  pkgs,
  inputs,
  system,
  lib,
  ...
}:

{
  programs.fish.enable = lib.mkForce true;

  users.users.${username} = {
    isNormalUser = true;
    name = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "media"
    ];
    shell = pkgs.fish;
  };

  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
    overlays = [ inputs.self.overlays.default ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings.experimental-features = "nix-command flakes";
    settings.download-buffer-size = 5000000000000000;
  };

  programs.ssh.askPassword = "";
  security.polkit.enable = true;
  security.rtkit.enable = true;
  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = "en_US.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_ADDRESS = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
    };
  };

  system.stateVersion = "24.05";
}
