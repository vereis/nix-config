# Home Manager style configuration.
{ config, pkgs, ... }:

{
  imports = [ ../profiles/chris.nix ];

  config.globals.username = "chris";
  config.home.username = config.globals.username;
  config.home.homeDirectory = "/home/${config.globals.username}";
  config.home.stateVersion = "21.05";
}
