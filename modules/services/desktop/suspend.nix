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
  cfg = config.modules.services.desktop.suspend;
  graphicsCfg = config.modules.services.desktop.graphics;
  isNvidia = graphicsCfg.enable && graphicsCfg.driver == "nvidia";
  isGnome = config.modules.services.desktop.gnome.enable or false;
in
{
  options.modules.services.desktop.suspend = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable suspend/resume fixes for common issues:
        - Systemd user session freezing bug
        - NVIDIA + GNOME Shell interaction bugs
        - USB device wakeup control
        - Double suspend prevention

        NVIDIA-specific fixes are automatically applied when NVIDIA driver is detected.
        GNOME-specific fixes are applied when GNOME (and NVIDIA) is enabled.
      '';
    };

    usb.disable = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            vendor = mkOption {
              type = types.str;
              description = "USB vendor ID (4-digit hex, e.g., '046d' for Logitech)";
              example = "046d";
            };
            product = mkOption {
              type = types.str;
              description = "USB product ID (4-digit hex)";
              example = "c52b";
            };
          };
        }
      );
      default = [ ];
      description = ''
        List of specific USB devices to disable wakeup for.
        Use `lsusb` to find vendor and product IDs.

        To disable ALL USB wakeup, use: [{ vendor = "*"; product = "*"; }]
      '';
      example = [
        {
          vendor = "046d";
          product = "c52b";
        }
      ];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Disable systemd user session freezing (affects ALL GPUs)
    # https://github.com/NixOS/nixpkgs/issues/371058
    {
      systemd.services = builtins.listToAttrs (
        map
          (service: {
            name = service;
            value.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
          })
          [
            "systemd-suspend"
            "systemd-hibernate"
            "systemd-hybrid-sleep"
            "systemd-suspend-then-hibernate"
          ]
      );
    }

    (mkIf isNvidia (mkMerge [
      # NVIDIA kernel parameters for proper suspend/resume
      # https://github.com/NixOS/nixpkgs/issues/336723
      {
        boot.kernelParams = [
          "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
          "nvidia.NVreg_TemporaryFilePath=/var/tmp"
        ];

        # Force-enable NVIDIA power management when using suspend fixes
        # PreserveVideoMemoryAllocations requires power management to be enabled
        # This creates nvidia-suspend.service and nvidia-resume.service
        modules.services.desktop.graphics.nvidia.powerManagement = true;
      }

      # Pause GNOME Shell during suspend to prevent NVIDIA driver interaction
      # Only applies if GNOME is enabled
      (mkIf isGnome {
        systemd.services.gnome-suspend = {
          description = "Suspend GNOME Shell before system suspend (prevents NVIDIA driver interaction)";
          before = [
            "systemd-suspend.service"
            "systemd-hibernate.service"
            "nvidia-suspend.service"
            "nvidia-hibernate.service"
          ];
          wantedBy = [
            "systemd-suspend.service"
            "systemd-hibernate.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.procps}/bin/pkill -f -STOP gnome-shell";
          };
        };

        systemd.services.gnome-resume = {
          description = "Resume GNOME Shell after system suspend";
          after = [
            "systemd-suspend.service"
            "systemd-hibernate.service"
            "nvidia-resume.service"
            "nvidia-hibernate.service"
          ];
          wantedBy = [
            "systemd-suspend.service"
            "systemd-hibernate.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.procps}/bin/pkill -f -CONT gnome-shell";
          };
        };
      })

      # Prevent double suspend
      # Reported for Framework laptops, but symtomatically affects other like mine
      {
        systemd.services.inhibit-sleep-after-resume = {
          description = "Temporary sleep inhibitor after resume (prevents double suspend)";
          wantedBy = [ "post-resume.target" ];
          after = [ "post-resume.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            ${pkgs.systemd}/bin/systemd-inhibit \
              --mode=block \
              --what=sleep:idle \
              --why="Workaround: avoid immediate second suspend after resume" \
              ${pkgs.coreutils}/bin/sleep 60
          '';
        };
      }
    ]))

    # USB wakeup control
    # Some machines get woken up by USB devices unintentionally
    (mkIf (cfg.usb.disable != [ ]) {
      services.udev.extraRules =
        let
          disableAll = builtins.any (dev: dev.vendor == "*" && dev.product == "*") cfg.usb.disable;

          # Generate rules for specific devices
          deviceRules = builtins.concatStringsSep "\n" (
            map (dev: ''
              ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="${dev.vendor}", ATTRS{idProduct}=="${dev.product}", ATTR{power/wakeup}="disabled"
            '') (builtins.filter (dev: dev.vendor != "*") cfg.usb.disable)
          );

          # Rule to disable all USB wakeup
          allUsbRule = ''
            ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
          '';
        in
        if disableAll then allUsbRule else deviceRules;
    })
  ]);
}
