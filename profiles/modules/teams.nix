{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.teams = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.teams.enable {
    home.packages = [ pkgs.teams ];
  };
}

