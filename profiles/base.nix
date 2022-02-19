{ config, lib, pkgs, ... }:

with lib;
{
  options.globals = {
    isWsl      = mkOption { type = types.bool; default = builtins.getEnv "WSL_DISTRO_NAME" != ""; };
    wslDistro  = mkOption { type = types.str; default = builtins.getEnv "WSL_DISTRO_NAME"; };

    isNixos    = mkOption { type = types.bool; default = builtins.pathExists /etc/NIXOS; };

    username   = mkOption { type = types.str; default = "chris"; };
    nixProfile = mkOption { type = types.str; default = "/home/" +  config.globals.username + "/.nix-profile"; };
    localBin   = mkOption { type = types.str; default = "/home/" + config.globals.username + "/.local/bin"; };
  };

  config = {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    home.sessionPath = [
      "${config.globals.localBin}"
      "$HOME/bin"
    ];

    home.sessionVariables = {
      NIX_PROFILE = config.globals.nixProfile;
    };
  };
}
