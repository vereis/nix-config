{
  pkgs,
  lib,
  config,
  copyparty,
  ...
}:

with lib;
{
  options.modules.copyparty = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    accounts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            password = mkOption {
              type = types.str;
              description = "Password for the account";
            };
          };
        }
      );
      default = { };
      description = "User accounts configuration";
    };

    volumes = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "Directory path to share";
            };
            access = mkOption {
              type = types.attrsOf (types.either types.str (types.listOf types.str));
              default = { };
              description = "Access permissions configuration";
            };
            flags = mkOption {
              type = types.attrsOf types.anything;
              default = { };
              description = "Volume-specific flags";
            };
          };
        }
      );
      default = { };
      description = "Volume configuration";
    };
  };

  config = mkIf config.modules.copyparty.enable {
    nixpkgs.overlays = [ copyparty.overlays.default ];
    environment.systemPackages = [ pkgs.copyparty ];

    # Add copyparty user to media group for file access
    users.users.copyparty = {
      extraGroups = [ "media" ];
    };

    # Ensure directories are writable by the media group with setgid bit
    systemd.tmpfiles.rules =
      let
        volumePaths = mapAttrsToList (_: v: v.path) config.modules.copyparty.volumes;
      in
      map (path: "Z ${path} 2775 root media - -") volumePaths;

    # Create password files for each account
    environment.etc = mapAttrs' (
      username: accountConfig:
      nameValuePair "copyparty/${username}.passwd" {
        text = accountConfig.password;
        mode = "0600";
        user = "copyparty";
        group = "copyparty";
      }
    ) config.modules.copyparty.accounts;

    services.copyparty = {
      enable = true;
      openFilesLimit = 8192;

      settings = {
        # Network Configuration
        i = "0.0.0.0";
        p = [
          3210
          3211
        ];

        # Server Behavior
        no-reload = true; # Disable live config reloading (restart service to apply changes)
        ignored-flag = false; # Don't ignore files marked with special flags

        # Reverse Proxy Configuration
        rproxy = -1; # Auto-detect reverse proxy mode (-1 = auto, 0 = disabled, 1 = enabled)
        xff-hdr = "x-forwarded-for"; # Trust X-Forwarded-For header from reverse proxy for real client IPs

        # Upload Configuration
        u2sz = 1024; # Maximum upload chunk size in MiB (1 GiB chunks, default is 96 for Cloudflare compatibility)

        # Performance Optimization
        j = 0; # Worker processes (0 = auto-detect and use all CPU cores for multiprocessing)

        # Indexing and Search
        e2dsa = true; # Scan and index all files on startup (enables full-text search and deduplication)
        e2ts = true; # Index metadata tags from media files (artist, title, album art, etc.)

        # Storage Optimization
        dedup = true; # Enable symlink-based deduplication to save disk space by detecting identical files

        # Social Media / Sharing
        og-ua = "(Discord|Twitter|Slack|Telegram)bot"; # Enable OpenGraph embeds only for social media bots (preserves hotlinking)

        # Quick Access
        qr = true; # Print QR code on startup for easy mobile access
      };

      # Configure accounts with password files
      accounts = mapAttrs (username: _: {
        passwordFile = "/etc/copyparty/${username}.passwd";
      }) config.modules.copyparty.accounts;

      inherit (config.modules.copyparty) volumes;
    };
  };
}
