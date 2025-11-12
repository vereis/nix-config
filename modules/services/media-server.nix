{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.media-server = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    mediaPath = mkOption {
      type = types.str;
      default = "/storage/media";
      description = "Path to media library";
    };
    user = mkOption {
      type = types.str;
      default = "plex";
      description = "User account under which Plex runs";
    };
    enableHardwareAcceleration = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hardware acceleration for transcoding";
    };
  };

  config = mkIf config.modules.media-server.enable {
    users.groups.media = { };

    services.plex = {
      enable = true;
      openFirewall = config.modules.media-server.openFirewall;
      user = config.modules.media-server.user;
      group = "media";
      dataDir = "/var/lib/plex";
      extraGroups = [ "media" ];
    };

    systemd.tmpfiles.rules = [
      "d ${config.modules.media-server.mediaPath} 0755 root media - -"
      "Z ${config.modules.media-server.mediaPath} 0755 root media - -"
    ];
  };
}
