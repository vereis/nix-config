{ config, pkgs, ... }:

{
  imports = [
    ./machines/tteokbokki.nix
  ];

  config.globals.username = "chris";

  config.home.username = config.globals.username;
  config.home.homeDirectory = "/home/${config.globals.username}";
  config.home.stateVersion = "21.05";
}
