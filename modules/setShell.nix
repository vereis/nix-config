{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.setShell = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.setShell.enable {
    home.file.".local/bin/set-shell" = {
      executable = true;
      source = ./setShell/set-shell;
    };
  };
}
