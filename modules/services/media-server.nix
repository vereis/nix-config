{
  pkgs,
  lib,
  config,
  secrets,
  ...
}:

with lib;

let
  cfg = config.modules.media-server;
  arrCfg = cfg.arr;
in
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
      type = types.addCheck types.str (p: lib.hasPrefix "/" p && p != "/" && p != "");
      apply = p: lib.removeSuffix "/" p;
      default = "/storage/media";
      example = "/storage/media";
      description = "Absolute path to media library";
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

    arr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable *arr stack (Sonarr/Radarr/Prowlarr/Lidarr/Bazarr/Jellyseerr/qBittorrent)";
      };

      downloadPath = mkOption {
        type = types.addCheck types.str (p: lib.hasPrefix "/" p && p != "/" && p != "");
        apply = p: lib.removeSuffix "/" p;
        default = "/storage/torrents";
        example = "/storage/torrents";
        description = "Absolute path to qBittorrent downloads (must be on same filesystem as media for hardlinks)";
      };

    };
  };

  config = mkIf cfg.enable {
    users = {
      groups.media = { };

      users = {
        jellyfin = mkIf cfg.jellyfin.enable {
          extraGroups = mkIf cfg.enableHardwareAcceleration [
            "video"
            "render"
          ];
        };

        plex = mkIf (cfg.plex.enable && cfg.enableHardwareAcceleration) {
          extraGroups = [
            "video"
            "render"
          ];
        };

        sonarr.extraGroups = mkIf arrCfg.enable [ "media" ];
        radarr.extraGroups = mkIf arrCfg.enable [ "media" ];
        lidarr.extraGroups = mkIf arrCfg.enable [ "media" ];
        bazarr.extraGroups = mkIf arrCfg.enable [ "media" ];
        qbittorrent.extraGroups = mkIf arrCfg.enable [ "media" ];
        readarr.extraGroups = mkIf arrCfg.enable [ "media" ];

        sonarr-anime = mkIf arrCfg.enable {
          isSystemUser = true;
          group = "media";
          home = "/var/lib/sonarr-anime";
          createHome = true;
        };

        radarr-anime = mkIf arrCfg.enable {
          isSystemUser = true;
          group = "media";
          home = "/var/lib/radarr-anime";
          createHome = true;
        };
      };
    };

    services = {
      plex = mkIf cfg.plex.enable {
        enable = true;
        inherit (cfg) openFirewall;
        inherit (cfg.plex) user;
        dataDir = "/var/lib/plex";
      };

      jellyfin = mkIf cfg.jellyfin.enable {
        enable = true;
        inherit (cfg) openFirewall;
        dataDir = "/var/lib/jellyfin";
      };

      sonarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        dataDir = "/var/lib/sonarr";
        settings.server = {
          port = 8989;
          bindAddress = "127.0.0.1";
        };
      };

      radarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        dataDir = "/var/lib/radarr";
        settings.server = {
          port = 7878;
          bindAddress = "127.0.0.1";
        };
      };

      prowlarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        dataDir = "/var/lib/prowlarr";
        settings.server = {
          port = 9696;
          bindAddress = "127.0.0.1";
        };
      };

      lidarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        dataDir = "/var/lib/lidarr";
        settings.server = {
          port = 8686;
          bindAddress = "127.0.0.1";
        };
      };

      bazarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        listenPort = 6767;
      };

      readarr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        dataDir = "/var/lib/readarr";
        group = "media";
        settings.server = {
          port = 8787;
          bindAddress = "127.0.0.1";
        };
      };

      jellyseerr = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        port = 5055;
      };

      qbittorrent = mkIf arrCfg.enable {
        enable = true;
        openFirewall = false;
        user = "qbittorrent";
        profileDir = "/var/lib/qbittorrent";
        webuiPort = 8080;
        torrentingPort = 6881;

        serverConfig = {
          Preferences = {
            Downloads = {
              SavePath = "${arrCfg.downloadPath}/";
            };

            WebUI = {
              Address = "127.0.0.1";
              Password_PBKDF2 = secrets.qbittorrent.webui.passwordPbkdf2;
              AuthSubnetWhitelist = "127.0.0.1/32";
              AuthSubnetWhitelistEnabled = true;
            };
          };
        };
      };
    };

    systemd.services.prowlarr.serviceConfig.SupplementaryGroups = mkIf arrCfg.enable [ "media" ];
    systemd.services.jellyseerr.serviceConfig.SupplementaryGroups = mkIf arrCfg.enable [ "media" ];

    # Resource limits to prevent thread leaks and runaway processes
    systemd.services.sonarr.serviceConfig.TasksMax = mkIf arrCfg.enable 4096;
    systemd.services.sonarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "2G";
    systemd.services.sonarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "1536M";
    systemd.services.sonarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 16384;

    systemd.services.radarr.serviceConfig.TasksMax = mkIf arrCfg.enable 4096;
    systemd.services.radarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "2G";
    systemd.services.radarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "1536M";
    systemd.services.radarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 16384;

    systemd.services.prowlarr.serviceConfig.TasksMax = mkIf arrCfg.enable 2048;
    systemd.services.prowlarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "1G";
    systemd.services.prowlarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "768M";
    systemd.services.prowlarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 8192;

    systemd.services.lidarr.serviceConfig.TasksMax = mkIf arrCfg.enable 4096;
    systemd.services.lidarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "2G";
    systemd.services.lidarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "1536M";
    systemd.services.lidarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 16384;

    systemd.services.readarr.serviceConfig.TasksMax = mkIf arrCfg.enable 4096;
    systemd.services.readarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "2G";
    systemd.services.readarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "1536M";
    systemd.services.readarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 16384;

    systemd.services.bazarr.serviceConfig.TasksMax = mkIf arrCfg.enable 2048;
    systemd.services.bazarr.serviceConfig.MemoryMax = mkIf arrCfg.enable "1G";
    systemd.services.bazarr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "768M";
    systemd.services.bazarr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 8192;

    systemd.services.jellyseerr.serviceConfig.TasksMax = mkIf arrCfg.enable 2048;
    systemd.services.jellyseerr.serviceConfig.MemoryMax = mkIf arrCfg.enable "1G";
    systemd.services.jellyseerr.serviceConfig.MemoryHigh = mkIf arrCfg.enable "768M";
    systemd.services.jellyseerr.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 8192;

    # Resource limits for Plex and qBittorrent to prevent swap thrashing
    systemd.services.plex.serviceConfig.TasksMax = mkIf cfg.plex.enable 256;
    systemd.services.plex.serviceConfig.MemoryMax = mkIf cfg.plex.enable "4G";
    systemd.services.plex.serviceConfig.MemoryHigh = mkIf cfg.plex.enable "3G";
    systemd.services.plex.serviceConfig.LimitNOFILE = mkIf cfg.plex.enable 32768;

    systemd.services.qbittorrent.serviceConfig.TasksMax = mkIf arrCfg.enable 2048;
    systemd.services.qbittorrent.serviceConfig.MemoryMax = mkIf arrCfg.enable "4G";
    systemd.services.qbittorrent.serviceConfig.MemoryHigh = mkIf arrCfg.enable "3G";
    systemd.services.qbittorrent.serviceConfig.LimitNOFILE = mkIf arrCfg.enable 32768;
    systemd.services.qbittorrent.serviceConfig.CPUQuota = mkIf arrCfg.enable "200%";

    systemd.services.sonarr-anime = mkIf arrCfg.enable {
      description = "Sonarr (Anime)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        SONARR__SERVER__PORT = "8990";
        SONARR__SERVER__BINDADDRESS = "127.0.0.1";
      };

      serviceConfig = {
        User = "sonarr-anime";
        Group = "media";
        StateDirectory = "sonarr-anime";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
        ExecStart = "${pkgs.sonarr}/bin/Sonarr -nobrowser -data=/var/lib/sonarr-anime";
        # Resource limits to prevent thread leaks
        TasksMax = 4096;
        MemoryMax = "2G";
        MemoryHigh = "1536M";
        LimitNOFILE = 16384;
      };
    };

    systemd.services.radarr-anime = mkIf arrCfg.enable {
      description = "Radarr (Anime)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        RADARR__SERVER__PORT = "7879";
        RADARR__SERVER__BINDADDRESS = "127.0.0.1";
      };

      serviceConfig = {
        User = "radarr-anime";
        Group = "media";
        StateDirectory = "radarr-anime";
        StateDirectoryMode = "0750";
        Restart = "on-failure";
        ExecStart = "${pkgs.radarr}/bin/Radarr -nobrowser -data=/var/lib/radarr-anime";
        # Resource limits to prevent thread leaks
        TasksMax = 4096;
        MemoryMax = "2G";
        MemoryHigh = "1536M";
        LimitNOFILE = 16384;
      };
    };

    hardware.graphics = mkIf cfg.enableHardwareAcceleration {
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
      "d ${cfg.mediaPath} 0755 root media - -"
      "Z ${cfg.mediaPath} 0755 root media - -"
    ]
    ++ (optionals arrCfg.enable [
      "d ${arrCfg.downloadPath} 0775 root media - -"
      "Z ${arrCfg.downloadPath} 0775 root media - -"

      "d ${arrCfg.downloadPath}/movies 0775 root media - -"
      "d ${arrCfg.downloadPath}/anime-movies 0775 root media - -"
      "d ${arrCfg.downloadPath}/shows 0775 root media - -"
      "d ${arrCfg.downloadPath}/anime 0775 root media - -"
      "d ${arrCfg.downloadPath}/music 0775 root media - -"

      "d ${cfg.mediaPath}/movies 0775 root media - -"
      "d ${cfg.mediaPath}/anime-movies 0775 root media - -"
      "d ${cfg.mediaPath}/shows 0775 root media - -"
      "d ${cfg.mediaPath}/anime 0775 root media - -"
      "d ${cfg.mediaPath}/music 0775 root media - -"
    ]);
  };
}
