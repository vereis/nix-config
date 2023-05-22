{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.radarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.radarr.enable {
    services.radarr = {
      enable = true;
      openFirewall = config.modules.radarr.openFirewall;
    };
  };
}
