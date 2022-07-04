{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.slack = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.slack.enable {
    home.packages = [ pkgs.slack ];
  };
}

