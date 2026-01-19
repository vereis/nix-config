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
      # NVIDIA Power Management (disabled by default due to NixOS bugs)
      #
      # NVIDIA's power management features are experimental on NixOS and cause
      # severe suspend/resume issues with GDM/GNOME (Issue #336723).
      #
      # Symptoms: After suspend, system requires multiple login attempts (3-10)
      # before staying awake. Screen blanks or system re-suspends immediately.
      #
      # Alternative: hardware.nvidia.powerManagement.finegrained
      # - Works on Turing (RTX 20-series) and newer GPUs
      # - Still experimental, may cause laptops to power off during power state changes
      # - Test thoroughly before relying on it
      #
      # To enable power management (at your own risk):
      #   modules.services.desktop.graphics.nvidia.powerManagement = true;
      #
      # References:
      # - https://github.com/NixOS/nixpkgs/issues/336723
      # - https://github.com/NixOS/nixpkgs/issues/254614
      powerManagement = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA power management. Disabled by default due to NixOS suspend/resume bugs (Issue #336723). May cause issues on some systems.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
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
