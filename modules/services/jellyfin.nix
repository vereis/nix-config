{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.jellyfin = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    nvidiaVaapi = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
    jellyseerr.enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.jellyfin.enable {
    environment.systemPackages = with pkgs; [ nvidia-vaapi-driver ];

    hardware.opengl = mkIf config.modules.jellyfin.nvidiaVaapi {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        nvidia-vaapi-driver
      ];
    };

    # Ensure a `media` group exists
    users.groups.media = { };

    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = config.modules.jellyfin.openFirewall;
    };

    services.jellyseerr = mkIf config.modules.jellyfin.jellyseerr.enable {
      enable = true;
      openFirewall = config.modules.jellyfin.openFirewall;
    };
  };
}
