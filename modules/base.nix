{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.base = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.base.enable {
    home.packages = [
      # Scripting
      pkgs.bash

      # Expected for all my workflows
      pkgs.tmux
      pkgs.tree
      pkgs.xclip
      pkgs.httpie
      pkgs.htop

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
