{ pkgs, secrets, ... }:

{
  imports = [
    ../../../modules/services/tailscale.nix
    ../../../modules/services/serve.nix
    ../../../modules/services/copyparty.nix
    ../../../modules/services/minecraft.nix
  ];

  modules.tailscale.enable = true;

  modules.copyparty.enable = true;
  modules.copyparty.accounts.vereis.password = secrets.copyparty.vereis;
  modules.copyparty.accounts.turtz.password = secrets.copyparty.turtz;
  modules.copyparty.volumes = {
    "/" = {
      path = "/storage";
      access = { rwmd = [ "turtz" ]; A = [ "vereis" ]; };
      flags = {
        fk = 4;
        scan = 60;
        e2d = true;
        nohash = "\.iso$";
        daw = true;
      };
    };
  };

  modules.serve = {
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
        ssl = false;
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
        streaming = true;
        realIpForwarding = true;
        gzipCompression = true;
        largeUploads = true;
        websocketSupport = true;
        sslOptimization = true;
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
        };
      };
    };
  };

  modules.minecraft = {
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
}
