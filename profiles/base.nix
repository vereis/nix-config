{ config, lib, pkgs, ... }:

with lib;
{
  options.globals = {
    isWsl      = mkOption { type = types.bool; default = builtins.getEnv "WSL_DISTRO_NAME" != ""; };
    wslDistro  = mkOption { type = types.str; default = builtins.getEnv "WSL_DISTRO_NAME"; };

    isNixos    = mkOption { type = types.bool; default = builtins.pathExists /etc/NIXOS; };

    username   = mkOption { type = types.str; default = "chris"; };
    nixProfile = mkOption { type = types.str; default = builtins.getEnv "HOME" + "/.nix-profile"; };
    localBin   = mkOption { type = types.str; default = builtins.getEnv "HOME" + "/.local/bin"; };
  };

  config = {
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
  };
}
