{ ... }:

{
  imports = [
    ../../../modules/services/tailscale.nix
    ../../../modules/services/docker.nix
    ../../../modules/services/desktop
    ../../../modules/hardware/blue-yeti.nix
  ];

  modules = {
    tailscale.enable = true;

    docker = {
      enable = true;
      rootless = true;
    };

    hardware.blue-yeti.enable = true;

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

      graphics = {
        enable = true;
        driver = "nvidia";
      };
      steam.enable = true;
    };
  };
}
