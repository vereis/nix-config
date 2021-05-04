{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.hub = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.hub.enable {
    home.packages = [
      pkgs.hub
    ];

    programs.zsh.initExtra = ''
      # == Start modules/hub.nix ==

      # Replace `git` with `hub`, since `hub` just provides a superset of functionality
      # this works really well :-)
      alias git=hub

      # == End modules/hub.nix ==
    '';
  };
}

