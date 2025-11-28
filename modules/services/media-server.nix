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
    enableHardwareAcceleration = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hardware acceleration for transcoding";
    };
    plex = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Plex Media Server";
      };
      user = mkOption {
        type = types.str;
        default = "plex";
        description = "User account under which Plex runs";
      };
    };
    jellyfin = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Jellyfin Media Server";
      };
    };
  };

  config = mkIf config.modules.media-server.enable {
    users.groups.media = { };

    services.plex = mkIf config.modules.media-server.plex.enable {
      enable = true;
      openFirewall = config.modules.media-server.openFirewall;
      user = config.modules.media-server.plex.user;
      group = "media";
      dataDir = "/var/lib/plex";
    };

    services.jellyfin = mkIf config.modules.media-server.jellyfin.enable {
      enable = true;
      openFirewall = config.modules.media-server.openFirewall;
      group = "media";
      dataDir = "/var/lib/jellyfin";
    };

    users.users.jellyfin = mkIf config.modules.media-server.jellyfin.enable {
      extraGroups = mkIf config.modules.media-server.enableHardwareAcceleration [
        "video"
        "render"
      ];
    };

    users.users.plex =
      mkIf
        (config.modules.media-server.plex.enable && config.modules.media-server.enableHardwareAcceleration)
        {
          extraGroups = [
            "video"
            "render"
          ];
        };

    hardware.graphics = mkIf config.modules.media-server.enableHardwareAcceleration {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${config.modules.media-server.mediaPath} 0755 root media - -"
      "Z ${config.modules.media-server.mediaPath} 0755 root media - -"
    ];
  };
}
