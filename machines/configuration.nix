{ self, system, username, pkgs, inputs, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    name = "${username}";
    extraGroups = [ "networkmanager" "wheel" "docker" "media" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

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

  security.polkit.enable = true;
  security.rtkit.enable = true;
  programs.ssh.askPassword = "";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "24.05";
}
