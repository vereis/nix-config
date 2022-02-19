{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ../modules/set-shell.nix
  ]; 

  options.modules.base = {
    enable = mkOption { type = types.bool; default = false; };
  };

  # TODO: this probably doesn't need to be optional
  config = mkIf config.modules.base.enable {
    modules.set-shell.enable = config.globals.isWsl;

    home.packages = [
      # Scripting
      pkgs.bash

      # Expected for all my workflows
      pkgs.git
      pkgs.tmux
      pkgs.tree
      pkgs.xclip
      pkgs.httpie
      pkgs.htop
      pkgs.sc-im

      pkgs.gnugrep # Busybox: misses some options I need
      pkgs.less    # Busybox: no color support

      # Generally useful
      pkgs.openssh
      pkgs.openssl
      pkgs.cacert
      pkgs.neofetch
    ];
  };
}
