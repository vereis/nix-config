{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.serve = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    firewallPorts = mkOption {
      type = types.listOf types.port;
      default = [
        80
        443
      ];
    };
    acmeEmail = mkOption {
      type = types.str;
      description = "Email address for ACME/Let's Encrypt certificates";
    };
    sites = mkOption {
      description = "Template for defining served sites.";
      type = types.attrsOf (
        types.submodule {
          options = {
            port = mkOption { type = types.port; };
            http2 = mkOption {
              type = types.bool;
              default = true;
            };
            ssl = mkOption {
              type = types.bool;
              default = false;
            };
            extraConfig = mkOption {
              type = types.str;
              default = "";
            };
            streaming = mkOption {
              type = types.bool;
              default = false;
              description = "Enable streaming optimizations (long timeouts, no buffering)";
            };
            realIpForwarding = mkOption {
              type = types.bool;
              default = false;
              description = "Forward real client IP and host headers";
            };
            gzipCompression = mkOption {
              type = types.bool;
              default = false;
              description = "Enable gzip compression for static content";
            };
            largeUploads = mkOption {
              type = types.bool;
              default = false;
              description = "Allow large file uploads (100MB limit)";
            };
            maxUploadSize = mkOption {
              type = types.str;
              default = "100M";
              description = "Maximum upload size (e.g., 100M, 1G, 2G)";
            };
            websocketSupport = mkOption {
              type = types.bool;
              default = false;
              description = "Enable WebSocket support";
            };
            sslOptimization = mkOption {
              type = types.bool;
              default = false;
              description = "Enable SSL optimizations (OCSP stapling, optimized ciphers)";
            };
            headers = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Custom proxy headers to set";
              example = {
                "X-Custom-Header" = "value";
              };
            };
            ddns = mkOption {
              type = types.nullOr (
                types.submodule {
                  options = {
                    enable = mkOption {
                      type = types.bool;
                      default = true;
                    };
                    protocol = mkOption {
                      type = types.enum [ "cloudflare" ];
                      default = "cloudflare";
                    };
                    login = mkOption { type = types.str; };
                    password = mkOption { type = types.str; };
                    zone = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                    };
                  };
                }
              );
              default = null;
              description = "DDNS configuration for this domain";
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf config.modules.serve.enable {
    networking.firewall.allowedTCPPorts = mkIf config.modules.serve.openFirewall config.modules.serve.firewallPorts;

    environment.systemPackages = with pkgs; [
      ddclient
    ];

    security.acme.acceptTerms = true;
    security.acme.defaults.email = config.modules.serve.acmeEmail;

    environment.etc."ddclient.conf" =
      let
        enabledDomains = lib.filterAttrs (
          _name: proxy: proxy.ddns != null && proxy.ddns.enable
        ) config.modules.serve.sites;
        hasEnabledDomains = enabledDomains != { };
      in
      mkIf hasEnabledDomains {
        text = ''
          use=web
          web=ipinfo.io/ip
          ssl=yes

          ${lib.concatStringsSep "\n\n" (
            lib.mapAttrsToList (domain: proxy: ''
              protocol=${proxy.ddns.protocol}
              login=${proxy.ddns.login}
              password=${proxy.ddns.password}
              ${lib.optionalString (proxy.ddns.zone != null) "zone=${proxy.ddns.zone}"}
              ${domain}
            '') enabledDomains
          )}
        '';
      };

    services.ddclient =
      let
        enabledDomains = lib.filterAttrs (
          _name: proxy: proxy.ddns != null && proxy.ddns.enable
        ) config.modules.serve.sites;
        hasEnabledDomains = enabledDomains != { };
      in
      mkIf hasEnabledDomains {
        enable = true;
        interval = "5min";
        configFile = "/etc/ddclient.conf";
      };

    users.users.ddclient =
      mkIf
        (
          lib.filterAttrs (_name: proxy: proxy.ddns != null && proxy.ddns.enable) config.modules.serve.sites
          != { }
        )
        {
          isSystemUser = true;
          group = "ddclient";
          home = "/var/lib/ddclient";
        };

    users.groups.ddclient = mkIf (
      lib.filterAttrs (_name: proxy: proxy.ddns != null && proxy.ddns.enable) config.modules.serve.sites
      != { }
    ) { };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = builtins.mapAttrs (
        _host: siteConfig:
        let
          streamingConfig = lib.optionalString siteConfig.streaming ''
            # Streaming optimizations
            send_timeout 100m;
            proxy_redirect off;
            proxy_buffering off;
          '';

          realIpConfig = lib.optionalString siteConfig.realIpForwarding ''
            # Forward real client IP and host
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $server_addr;
            proxy_set_header Referer $server_addr;
            proxy_set_header Origin $server_addr;
          '';

          gzipConfig = lib.optionalString siteConfig.gzipCompression ''
            # Gzip compression
            gzip on;
            gzip_vary on;
            gzip_min_length 1000;
            gzip_proxied any;
            gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
            gzip_disable "MSIE [1-6]\.";
          '';

          uploadConfig = lib.optionalString siteConfig.largeUploads ''
            # Large upload support
            client_max_body_size ${siteConfig.maxUploadSize};
          '';

          websocketConfig = lib.optionalString siteConfig.websocketSupport ''
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';

          sslConfig = lib.optionalString siteConfig.sslOptimization ''
            # SSL optimizations
            ssl_stapling on;
            ssl_stapling_verify on;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
          '';

          customHeaders = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: "proxy_set_header ${name} ${value};") siteConfig.headers
          );

          generatedConfig = lib.concatStringsSep "\n\n" (
            lib.filter (s: s != "") [
              streamingConfig
              realIpConfig
              gzipConfig
              uploadConfig
              websocketConfig
              sslConfig
              customHeaders
            ]
          );

          finalExtraConfig =
            if generatedConfig != "" then
              if siteConfig.extraConfig != "" then
                generatedConfig + "\n\n" + siteConfig.extraConfig
              else
                generatedConfig
            else
              siteConfig.extraConfig;
        in
        {
          enableACME = siteConfig.ssl;
          forceSSL = siteConfig.ssl;
          locations."/".proxyPass = "http://127.0.0.1:${toString siteConfig.port}/";
          locations."/".proxyWebsockets = true;
          inherit (siteConfig) http2;
          extraConfig = finalExtraConfig;
        }
      ) config.modules.serve.sites;
    };
  };
}
