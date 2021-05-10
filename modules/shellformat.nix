{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.shellformat = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.shellformat.enable {
    home.packages = [
      pkgs.shfmt
    ];
  };
}
