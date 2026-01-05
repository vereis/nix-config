{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.services.desktop.graphics;
in
{
  options.modules.services.desktop.graphics = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable graphics configuration with NVIDIA drivers optimized for gaming and Wayland.";
    };

    nvidia = {
      powerManagement = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NVIDIA power management (helps with sleep/hibernation, may cause issues on some systems).";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      powerManagement.enable = cfg.nvidia.powerManagement;
      powerManagement.finegrained = false;
      nvidiaPersistenced = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    boot = {
      kernelModules = [ "snd_hda_intel" ];
      extraModprobeConfig = ''
        options snd-hda-intel model=auto
      '';
    };

    environment = {
      systemPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
        nvidia-vaapi-driver
      ];

      sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
  };
}
