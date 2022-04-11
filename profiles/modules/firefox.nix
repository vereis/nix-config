{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.firefox = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.firefox.enable {
    home.packages = [pkgs.firefox];
  };
}

