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

      gnome.enable = true;

      graphics = {
        enable = true;
        driver = "intel";
      };

      steam.enable = true;
    };
  };
}
