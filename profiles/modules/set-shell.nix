{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.set-shell = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.set-shell.enable {
    home.file.".local/bin/set-shell" = {
      executable = true;
      source = ./set-shell/set-shell;
    };
  };
}
