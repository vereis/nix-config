{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.radarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.radarr.enable {
    # Ensure a `media` group exists
    users.groups.media = { };

    services.radarr = {
      enable = true;
      group = "media";
      openFirewall = config.modules.radarr.openFirewall;
    };
  };
}
