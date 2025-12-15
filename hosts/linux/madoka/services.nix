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

      gnome = {
        enable = true;
        altDrag = true;
        extraGSettings = {
          "org.gnome.desktop.session" = {
            # Disable idle timeout (prevents screen from auto-dimming/locking)
            idle-delay = "uint32 0";
          };
        };
      };

      graphics.enable = true;
      steam.enable = true;
    };
  };
}
