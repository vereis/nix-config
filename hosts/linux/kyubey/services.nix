{
  pkgs,
  lib,
  secrets,
  ...
}:

let
  # Tailscale-only *arr sites (no SSL, no DDNS - DNS manually points to Tailscale IP)
  arrSites = {
    "shows.vereis.com" = 8989;
    "anime.vereis.com" = 8990;
    "movies.vereis.com" = 7878;
    "anime-movies.vereis.com" = 7879;
    "indexers.vereis.com" = 9696;
    "music.vereis.com" = 8686;
    "subtitles.vereis.com" = 6767;
    "requests.vereis.com" = 5055;
    "torrents.vereis.com" = 8080;
    "books.vereis.com" = 8787;
  };

  arrServeSites = lib.mapAttrs (_name: port: {
    inherit port;
    ssl = false;
  }) arrSites;

in
{
  imports = [
    ../../../modules/services/tailscale.nix
    ../../../modules/services/serve.nix
    ../../../modules/services/copyparty.nix
    ../../../modules/services/minecraft.nix
    ../../../modules/services/media-server.nix
  ];

  modules = {
    tailscale.enable = true;

    serve = {
      enable = true;
      openFirewall = true;
      acmeEmail = "serve@vereis.com";

      sites = {
        "minecraft.vereis.com" = {
          port = 25565;
          ssl = true;
          ddns = {
            enable = true;
            protocol = "cloudflare";
            login = "token";
            password = secrets.cloudflare.ddclient;
            zone = "vereis.com";
          };
        };

        "files.vereis.com" = {
          port = 3210;
          ssl = true;
          largeUploads = true;
          maxUploadSize = "2G";
          ddns = {
            enable = true;
            protocol = "cloudflare";
            login = "token";
            password = secrets.cloudflare.ddclient;
            zone = "vereis.com";
          };
        };

        "plex.vereis.com" = {
          port = 32400;
          ssl = true;
          streaming = true;
          realIpForwarding = true;
          gzipCompression = true;
          largeUploads = true;
          websocketSupport = true;
          sslOptimization = true;
          ddns = {
            enable = true;
            protocol = "cloudflare";
            login = "token";
            password = secrets.cloudflare.ddclient;
            zone = "vereis.com";
          };
          headers = {
            "X-Plex-Client-Identifier" = "$http_x_plex_client_identifier";
            "X-Plex-Device" = "$http_x_plex_device";
            "X-Plex-Device-Name" = "$http_x_plex_device_name";
            "X-Plex-Platform" = "$http_x_plex_platform";
            "X-Plex-Platform-Version" = "$http_x_plex_platform_version";
            "X-Plex-Product" = "$http_x_plex_product";
            "X-Plex-Token" = "$http_x_plex_token";
            "X-Plex-Version" = "$http_x_plex_version";
            "X-Plex-Nocache" = "$http_x_plex_nocache";
            "X-Plex-Provides" = "$http_x_plex_provides";
            "X-Plex-Device-Vendor" = "$http_x_plex_device_vendor";
            "X-Plex-Model" = "$http_x_plex_model";
            "X-Forwarded-For" = "$proxy_add_x_forwarded_for";
            "X-Forwarded-Proto" = "$scheme";
            "X-Forwarded-Host" = "$host";
            "Host" = "127.0.0.1:32400";
            "Referer" = "$scheme://127.0.0.1:32400";
            "Origin" = "http://127.0.0.1:32400";
          };
        };

        "jellyfin.vereis.com" = {
          port = 8096;
          ssl = true;
          streaming = true;
          realIpForwarding = true;
          gzipCompression = true;
          largeUploads = true;
          websocketSupport = true;
          sslOptimization = true;
          ddns = {
            enable = true;
            protocol = "cloudflare";
            login = "token";
            password = secrets.cloudflare.ddclient;
            zone = "vereis.com";
          };
        };
      }
      // arrServeSites;
    };

    minecraft = {
      enable = true;
      openFirewall = true;

      servers.minnacraft = {
        enable = true;
        autoStart = true;
        package = pkgs.minecraftServers.paper-1_21_8;
        jvmOpts = "-Xms6144M -Xmx8192M";

        serverProperties = {
          difficulty = 3;
          gamemode = 1;
          max-players = 999;
          view-distance = 32;
          simulation-distance = 10;
          enable-command-block = true;
          motd = "minna, asobou yo~!!";

          enable-rcon = true;
          "rcon.password" = secrets.minecraft.minnacraft.rcon.password;
          "rcon.port" = secrets.minecraft.minnacraft.rcon.port;

          online-mode = true;
          spawn-protection = 16;
          player-idle-timeout = 30;
          network-compression-threshold = 256;

          spawn-animals = true;
          spawn-monsters = true;
          generate-structures = true;
        };
      };
    };

    media-server = {
      enable = true;
      openFirewall = true;
      mediaPath = "/storage/media";
      enableHardwareAcceleration = true;
      plex.enable = true;
      jellyfin.enable = true;
      arr.enable = true;
    };

    copyparty = {
      enable = true;
      accounts.vereis.password = secrets.copyparty.vereis;
      accounts.turtz.password = secrets.copyparty.turtz;
      volumes = {
        "/" = {
          path = "/storage";
          access = {
            rwmd = [ "turtz" ];
            A = [ "vereis" ];
          };
          flags = {
            fk = 4;
            scan = 60;
            e2d = true;
            nohash = "\.iso$";
            nsort = true; # Natural sort: file2.txt comes before file10.txt
          };
        };
      };
    };
  };
}
