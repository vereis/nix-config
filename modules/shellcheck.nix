{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.shellcheck = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.shellcheck.enable {
    home.packages = [
      pkgs.shellcheck
    ];
  };
}
