{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.prowlarr = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    user = mkOption {
      type = types.str;
      default = "sonarr";
      description = lib.mdDoc "User account under which Prowlarr runs.";
    };
    group = mkOption {
      type = types.str;
      default = "sonarr";
      description = lib.mdDoc "Group under which Prowlarr runs.";
    };
  };

  config = mkIf config.modules.prowlarr.enable {
    services.prowlarr = {
      enable = true;
      openFirewall = config.modules.prowlarr.openFirewall;
    };

    # Ensure that the prowlarr group and user exists if unset
    users.users = mkIf (config.modules.prowlarr.user == "prowlarr") { prowlarr = { }; };
    users.groups = mkIf (config.modules.prowlarr.group == "prowlarr") { prowlarr = { }; };

    # And overwrite prowlarr's default systemd unit to run with the correct user/group
    systemd.services.prowlarr = {
      serviceConfig = {
        User = config.modules.prowlarr.user;
        Group = config.modules.prowlarr.group;
      };
    };
  };
}
