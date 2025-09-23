{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.readarr = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.readarr.enable {
    # Ensure a `media` group exists
    users.groups.media = { };

    services.readarr = {
      enable = true;
      group = "media";
      openFirewall = config.modules.readarr.openFirewall;
    };
  };
}
