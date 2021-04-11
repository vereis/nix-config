{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.stdenv = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.stdenv.enable {
    home.packages = [
      # Scripting
      pkgs.bash

      # Expected for all my workflows
      pkgs.tmux
      pkgs.tree
      pkgs.xclip
      pkgs.httpie

      pkgs.gnugrep # Busybox: misses some options I need
      pkgs.less    # Busybos: no color support

      # Generally useful
      pkgs.openssh
      pkgs.openssl
      pkgs.cacert
      pkgs.neofetch
    ];
  };
}
