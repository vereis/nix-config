{
  lib,
  pkgs,
  config,
  ...
}:

let
  isPre70Kernel = lib.versionOlder config.boot.kernelPackages.kernel.version "7.0";

  ov02c10Backports = lib.optionals isPre70Kernel [
    {
      # Fixes wrong webcam colors after upstream OV02C10 flip changes.
      name = "ov02c10-fix-bayer-pattern-after-default-vflip";
      patch = pkgs.fetchurl {
        url = "https://github.com/torvalds/linux/commit/905120d7470e5ed79d59b61ef6aa13344ffca229.patch";
        hash = "sha256-Tir4Z6yP/t1mlpj6+fWLoWFa9tZ/8aEVEDWj7Wk4ajc=";
      };
    }
    {
      # Keeps colors stable when apps toggle camera flip controls.
      name = "ov02c10-preserve-bayer-pattern-on-flip-changes";
      patch = pkgs.fetchurl {
        url = "https://github.com/torvalds/linux/commit/d0bb6f1f2b79d96953bf81a3839ac2aa946ba2fa.patch";
        hash = "sha256-Fad0aRdKTkCALz5oFB1mJ7KJQ8XIXyvIK/ArAWUYhrw=";
      };
    }
    {
      # Fixes mirrored image behavior from the sensor hflip control.
      name = "ov02c10-fix-horizontal-flip-control";
      patch = pkgs.fetchurl {
        url = "https://github.com/torvalds/linux/commit/1d2e3b4443a85374fdd6fb8fd2c015e3e3e16100.patch";
        hash = "sha256-4qEYNDWYoxI2/UGTAGv+uEa38jx9eCNjEkYZk+zlEDA=";
      };
    }
  ];

  ov02c10ForcePatch =
    if isPre70Kernel then
      ./0001-ov02c10-force-default-rotation-180.patch
    else
      ./0001-ov02c10-force-default-rotation-180-v7.patch;
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages_testing;

    kernelPatches = ov02c10Backports ++ [
      {
        # Prevents userspace from flipping this webcam upside down.
        name = "ov02c10-force-default-rotation-180";
        patch = ov02c10ForcePatch;
      }
    ];

    extraModulePackages = [
      (config.boot.kernelPackages.callPackage ../../../../../packages/linux/ipu7-drivers/default.nix { })
      (config.boot.kernelPackages.callPackage ../../../../../packages/linux/vision-drivers/default.nix
        { }
      )
    ];

    extraModprobeConfig = ''
      options v4l2loopback devices=0
      softdep intel_cvs pre: usbio gpio_usbio i2c_usbio
      softdep ov02c10 pre: intel_cvs
    '';

    kernelModules = [
      "usbio"
      "gpio_usbio"
      "i2c_usbio"
      "intel_cvs"
      "intel_skl_int3472_common"
      "intel_skl_int3472_discrete"
      "ov02c10"
    ];
  };

  hardware.firmware = with pkgs; [
    ipu7-camera-bins
    ivsc-firmware
  ];

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="intel-ipu7-psys", MODE="0660", GROUP="video"
    '';

    # PipeWire apps should use the stable libcamera source, not raw IPU nodes.
    pipewire.wireplumber.extraConfig."90-ipu7-camera" = {
      "wireplumber.profiles" = {
        main = {
          "monitor.libcamera" = "required";
        };
      };

      "monitor.v4l2.rules" = [
        {
          matches = [
            {
              "api.v4l2.path" = "~^/dev/video([0-9]|[12][0-9]|3[01])$";
            }
          ];
          actions = {
            update-props = {
              "device.disabled" = true;
              "node.disabled" = true;
            };
          };
        }
        {
          matches = [
            {
              "api.v4l2.path" = "/dev/video32";
            }
          ];
          actions = {
            update-props = {
              "node.disabled" = true;
            };
          };
        }
      ];
    };

    # Creates a compatibility /dev/video node for apps like Slack and Teams.
    v4l2-relayd.instances.ipu7 = {
      enable = true;
      cardLabel = "Intel MIPI Camera";
      extraPackages = [ pkgs.icamerasrc-ipu7x ];
      input = {
        pipeline = "icamerasrc";
        format = "NV12";
      };
    };
  };

}
