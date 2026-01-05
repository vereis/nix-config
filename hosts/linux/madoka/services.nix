{ ... }:

{
  imports = [
    ../../../modules/services/tailscale.nix
    ../../../modules/services/docker.nix
    ../../../modules/services/desktop
  ];

  modules = {
    tailscale.enable = true;

    docker = {
      enable = true;
      rootless = true;
    };

    services.desktop = {
      autoLogin = true;

      niri = {
        enable = true;
        outputs."DP-2" = {
          mode = {
            width = 3840;
            height = 2160;
            refresh = 143.982;
          };
          scale = 1.0;
        };
      };

      graphics.enable = true;
      steam.enable = true;
    };
  };
}
