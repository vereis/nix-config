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
    # NOTE: Enable nix-ld for FHS-wrapped apps (like OnlyOffice) to find system libraries
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libGL
        libGLU
        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
        xorg.libXext
        xorg.libXrender
        xorg.libXfixes
      ];
    };

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
        GBM_BACKEND = "nvidia-drm";
        WLR_NO_HARDWARE_CURSORS = "1";
      };

      # NVIDIA application profile to fix high VRAM usage in niri
      # See: https://github.com/YaLTeR/niri/wiki/Nvidia#high-vram-usage-fix
      etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
        builtins.toJSON {
          rules = [
            {
              pattern = {
                feature = "procname";
                matches = "niri";
              };
              profile = "Limit Free Buffer Pool On Wayland Compositors";
            }
          ];
          profiles = [
            {
              name = "Limit Free Buffer Pool On Wayland Compositors";
              settings = [
                {
                  key = "GLVidHeapReuseRatio";
                  value = 0;
                }
              ];
            }
          ];
        };
    };
  };
}
