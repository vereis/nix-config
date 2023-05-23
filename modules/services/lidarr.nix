{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.lidarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.lidarr.enable {
    # Ensure a `media` group exists
    users.groups.media = { };

    services.lidarr = {
      enable = true;
      group = "media";
      openFirewall = config.modules.lidarr.openFirewall;
    };
  };
}
