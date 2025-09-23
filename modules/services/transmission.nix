{
  pkgs,
  lib,
  config,
  username,
  ...
}:

with lib;
{
  options.modules.transmission = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    downloadDir = mkOption {
      type = types.str;
      default = "/var/lib/transmission/downloads";
    };
  };

  config = mkIf config.modules.transmission.enable {
    environment.systemPackages = with pkgs; [
      transmission
      transmission-gtk
    ];

    # Ensure a `media` group exists
    users.groups.media = { };

    services.transmission = {
      enable = true;
      group = "media";
      downloadDirPermissions = "775";

      openFirewall = config.modules.transmission.openFirewall;
      openRPCPort = config.modules.transmission.openFirewall;
      openPeerPorts = config.modules.transmission.openFirewall;
      settings = mkIf config.modules.transmission.openFirewall {
        # The default values of these is in `/var/lib/transmission/downloads`, which
        # might be fine unless we're relying on external applications being able to
        # read/write to this directory.
        download-dir = "${config.modules.transmission.downloadDir}/default";
        incomplete-dir = "${config.modules.transmission.downloadDir}/incomplete";

        # Quality of life
        download-queue-size = 20;
        peer-limit-global = 2600;
        peer-limit-per-torrent = 130;

        # Remote access / webui configuration
        rpc-enabled = true;
        rpc-authentication-required = true;
        rpc-username = username;
        rpc-password = "password";
        rpc-whitelist-enabled = false;
        rpc-bind-address = "0.0.0.0";

        # Disable seeding
        upload-slots-per-torrent = 1;
        speed-limit-up = 0;
        speed-limit-up-enabled = true;
        seed-queue-enabled = false;
        seed-queue-size = 1;
        ratio-limit = 0.1;
        ratio-limit-enabled = true;
        idle-seeding-limit = 1;
        idle-seeding-limit-enabled = true;
      };
    };
  };
}
