{ pkgs, lib, config, username, copyparty, ... }:

with lib;
{
  options.modules.copyparty = {
    enable = mkOption { type = types.bool; default = false; };

    accounts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          password = mkOption {
            type = types.str;
            description = "Password for the account";
          };
        };
      });
      default = {};
      description = "User accounts configuration";
    };

    volumes = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Directory path to share";
          };
          access = mkOption {
            type = types.attrsOf (types.either types.str (types.listOf types.str));
            default = {};
            description = "Access permissions configuration";
          };
          flags = mkOption {
            type = types.attrsOf types.anything;
            default = {};
            description = "Volume-specific flags";
          };
        };
      });
      default = {};
      description = "Volume configuration";
    };
  };

  config = mkIf config.modules.copyparty.enable {
    nixpkgs.overlays = [ copyparty.overlays.default ];
    environment.systemPackages = with pkgs; [ copyparty  ];

    # Create password files for each account
    environment.etc = mapAttrs' (username: accountConfig:
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
        i = "0.0.0.0";
        p = [ 3210 3211 ];
        no-reload = true;
        ignored-flag = false;
      };

      # Configure accounts with password files
      accounts = mapAttrs (username: accountConfig: {
        passwordFile = "/etc/copyparty/${username}.passwd";
      }) config.modules.copyparty.accounts;

      volumes = config.modules.copyparty.volumes;
    };
  };
}
