{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.wslUtils = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf (config.globals.isWsl && config.modules.wslUtils.enable) {
    home.file.".local/bin/edge" = {
      executable = true;
      source = ./wslUtils/edge;
    };

    home.sessionVariables = {
      BROWSER = "edge";
    };
  };
}
