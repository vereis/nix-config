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

      gnome.enable = true;

      graphics = {
        enable = true;
        driver = "nvidia";
      };
      steam.enable = true;
    };
  };
}
