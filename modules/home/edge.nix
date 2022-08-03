{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.edge = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.edge.enable {
    home.packages = with pkgs; [ microsoft-edge ];

    home.sessionVariables = {
      BROWSER = "microsoft-edge";
    };
  };
}
