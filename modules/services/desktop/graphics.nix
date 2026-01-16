{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    mkMerge
    types
    ;
  cfg = config.modules.services.desktop.graphics;
in
{
  options.modules.services.desktop.graphics = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable graphics configuration with hardware acceleration.";
    };

    driver = mkOption {
      type = types.nullOr (
        types.enum [
          "nvidia"
          "intel"
          "amd"
        ]
      );
      default = null;
      description = "GPU driver to configure. null = basic OpenGL only.";
    };

    nvidia = {
      powerManagement = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NVIDIA power management (helps with sleep/hibernation, may cause issues on some systems).";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common config for all drivers
    {
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

      security.rtkit.enable = true;

      boot = {
        kernelModules = [ "snd_hda_intel" ];
        extraModprobeConfig = ''
          options snd-hda-intel model=auto
        '';
      };

      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };

      environment.systemPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
      ];
    }

    # NVIDIA-specific config
    (mkIf (cfg.driver == "nvidia") {
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

      environment = {
        systemPackages = with pkgs; [
          nvidia-vaapi-driver
        ];

        sessionVariables = {
          LIBVA_DRIVER_NAME = "nvidia";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          WLR_NO_HARDWARE_CURSORS = "1";
        };
      };
    })

    # Intel-specific config
    (mkIf (cfg.driver == "intel") {
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vpl-gpu-rt
      ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };
    })

    # AMD-specific config (placeholder for future use)
    (mkIf (cfg.driver == "amd") {
      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.graphics.extraPackages = with pkgs; [
        amdvlk
      ];

      hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
        amdvlk
      ];
    })
  ]);
}
