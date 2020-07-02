{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "cbailey.co.uk";

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  environment.systemPackages = with pkgs; [
    git 
    wget
    vim
    direnv
    tmux
  ];

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  users.users.root.shell = pkgs.zsh;

  services.lorri.enable = true;

  # Open up webserver
  networking.firewall.allowedTCPPorts = [22 80 443];

  security.acme.acceptTerms = true;
  security.acme.certs."cbailey.co.uk" = {
    email = "me@cbailey.co.uk";
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    commonHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Enable CSP for your services.
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # Enable XSS protection of the browser.
      # May be unnecessary when CSP is configured properly (see above)
      add_header X-XSS-Protection "1; mode=block";

      # This might create errors
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';

    virtualHosts = let
      base = locations: {
        inherit locations;

        forceSSL = true;
        enableACME = true;
      };
      proxy = port: base {
        "/".proxyPass = "http://127.0.0.1:" + toString(port) + "/";
      };
      webroot = "/srv/blog/apps/blog_web/assets/static/assets";
    in {
      "cbailey.co.uk" = proxy 4000 // { default = true; };
    };
  };
}
