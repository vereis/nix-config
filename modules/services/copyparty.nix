{ pkgs, lib, config, username, copyparty, ... }:

with lib;
{
  options.modules.copyparty = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.copyparty.enable {
    nixpkgs.overlays = [ copyparty.overlays.default ];
    environment.systemPackages = with pkgs; [ copyparty  ];

    services.copyparty = {
      enable = true;
      openFilesLimit = 8192;

      settings = {
        i = "0.0.0.0";
        p = [ 3210 3211 ];
        no-reload = true;
        ignored-flag = false;
      };

      volumes = {
        "/" = {
          path = "/storage";
          access = { rw = "*"; };

          flags = {
            fk = 4;
            scan = 60;
            e2d = true;
            nohash = "\.iso$";
          };
        };
      };
    };
  };
}
