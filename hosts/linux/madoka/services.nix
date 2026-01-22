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

      suspend = {
        enable = true;
        usb.disable = [
          {
            vendor = "046d";
            product = "c548";
          } # Logitech USB Receiver
          {
            vendor = "046d";
            product = "c52b";
          } # Logitech USB Receiver
        ];
      };

      steam.enable = true;
    };
  };
}
