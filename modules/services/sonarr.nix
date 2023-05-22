{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.sonarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.sonarr.enable {
    services.sonarr = {
      enable = true;
      openFirewall = config.modules.sonarr.openFirewall;
    };
  };
}
