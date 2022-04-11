{ config, lib, pkgs, ... }:

with lib;
{
  config = {
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
