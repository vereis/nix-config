{ pkgs, secrets, ... }:

{
  imports = [
    ../../../modules/services/tailscale.nix
    ../../../modules/services/proxy.nix
    ../../../modules/services/copyparty.nix
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

  modules.proxy.enable = true;
  modules.proxy.openFirewall = true;
  modules.proxy.proxies = {
    "files.vereis.com" = { port = 3210; useSSL = false; };
    "jellyfin.vereis.com" = { port = 8096; };
    "sonarr.vereis.com" = { port = 8989; useSSL = false; };
    "radarr.vereis.com" = { port = 7878; useSSL = false; };
    "prowlarr.vereis.com" = { port = 9696; useSSL = false; };
    "transmission.vereis.com" = { port = 9091; useSSL = false; };
    "lidarr.vereis.com" = { port = 8686; useSSL = false; };
    "readarr.vereis.com" = { port = 8787; useSSL = false; };
    "printer.vereis.com" = { port = 631; useSSL = false; };
    "jellyseerr.vereis.com" = { port = 5055; useSSL = false; };
    "plex.vereis.com" = { port = 32400; extraConfig = ''
      # Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
      send_timeout 100m;

      # Why this is important: https://blog.cloudflare.com/ocsp-stapling-how-cloudflare-just-made-ssl-30/
      ssl_stapling on;
      ssl_stapling_verify on;

      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
      ssl_prefer_server_ciphers on;
      #Intentionally not hardened for security for player support and encryption video streams has a lot of overhead with something like AES-256-GCM-SHA384.
      ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

      # Forward real ip and host to Plex
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $server_addr;
      proxy_set_header Referer $server_addr;
      proxy_set_header Origin $server_addr;

      # Plex has A LOT of javascript, xml and html. This helps a lot, but if it causes playback issues with devices turn it off.
      gzip on;
      gzip_vary on;
      gzip_min_length 1000;
      gzip_proxied any;
      gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
      gzip_disable "MSIE [1-6]\.";

      # Nginx default client_max_body_size is 1MB, which breaks Camera Upload feature from the phones.
      # Increasing the limit fixes the issue. Anyhow, if 4K videos are expected to be uploaded, the size might need to be increased even more
      client_max_body_size 100M;

      # Plex headers
      proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
      proxy_set_header X-Plex-Device $http_x_plex_device;
      proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
      proxy_set_header X-Plex-Platform $http_x_plex_platform;
      proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
      proxy_set_header X-Plex-Product $http_x_plex_product;
      proxy_set_header X-Plex-Token $http_x_plex_token;
      proxy_set_header X-Plex-Version $http_x_plex_version;
      proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
      proxy_set_header X-Plex-Provides $http_x_plex_provides;
      proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
      proxy_set_header X-Plex-Model $http_x_plex_model;

      # Websockets
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";

      # Buffering off send to the client as soon as the data is received from Plex.
      proxy_redirect off;
      proxy_buffering off;
    '';
    };
  };
}
