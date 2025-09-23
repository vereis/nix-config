{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.sonarr = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.sonarr.enable {
    # Ensure a `media` group exists
    users.groups.media = { };

    services.sonarr = {
      enable = true;
      group = "media";
      openFirewall = config.modules.sonarr.openFirewall;
    };
  };
}
