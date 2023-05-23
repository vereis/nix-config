{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.lidarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.lidarr.enable {
    services.lidarr = {
      enable = true;
      openFirewall = config.modules.lidarr.openFirewall;
    };
  };
}
