{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.ripgrep = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.ripgrep.enable {
    home.packages = [
      pkgs.ripgrep
    ];
  };
}
