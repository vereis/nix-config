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
        Enable suspend/resume fixes and custom auto-suspend:
        - Systemd user session freezing bug
        - NVIDIA + GNOME Shell interaction bugs
        - USB device wakeup control
        - Double suspend prevention
        - Custom auto-suspend that bypasses GNOME's broken inhibitor system

        NVIDIA-specific fixes are automatically applied when NVIDIA driver is detected.
        GNOME-specific fixes are applied when GNOME (and NVIDIA) is enabled.
        Auto-suspend ignores all app inhibitors.
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

    idleMinutesAC = mkOption {
      type = types.ints.unsigned;
      default = 15;
      description = "Suspend after this many minutes idle on AC power (0 = never)";
    };

    idleMinutesBattery = mkOption {
      type = types.ints.unsigned;
      default = 15;
      description = "Suspend after this many minutes idle on battery (0 = never)";
    };

    checkIntervalMinutes = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "How often to check idle time (minutes, minimum 1)";
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

    # Custom auto-suspend service
    (mkIf cfg.enable {
      systemd.user.services.auto-suspend-idle-check = {
        description = "Check idle time and suspend if threshold exceeded";
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ImportEnvironment = "DBUS_SESSION_BUS_ADDRESS DISPLAY WAYLAND_DISPLAY";
        };
        path = with pkgs; [
          libnotify
          systemd
          gawk
          util-linux
          coreutils
        ];
        script = ''
          # Prevent overlapping executions
          exec 200>/tmp/auto-suspend-idle-check.lock
          flock -n 200 || exit 0

          # Get current idle time in milliseconds
          IDLE_MS=$(${pkgs.systemd}/bin/busctl --user call \
            org.gnome.Mutter.IdleMonitor \
            /org/gnome/Mutter/IdleMonitor/Core \
            org.gnome.Mutter.IdleMonitor \
            GetIdletime 2>/dev/null | awk '{print $2}')

          # Abort if idle time unavailable
          if [ -z "$IDLE_MS" ] || ! [[ "$IDLE_MS" =~ ^[0-9]+$ ]]; then
            echo "Failed to get idle time from Mutter" | ${pkgs.systemd}/bin/systemd-cat -t auto-suspend -p warning
            exit 0
          fi

          ON_BATTERY=$(${pkgs.systemd}/bin/busctl --system get-property \
            org.freedesktop.UPower \
            /org/freedesktop/UPower \
            org.freedesktop.UPower \
            OnBattery 2>/dev/null | awk '{print $2}')

          # Default to AC if UPower unavailable
          [ -z "$ON_BATTERY" ] && ON_BATTERY="false"

          if [ "$ON_BATTERY" = "false" ]; then
            THRESHOLD_MS=$((${toString cfg.idleMinutesAC} * 60 * 1000))
          else
            THRESHOLD_MS=$((${toString cfg.idleMinutesBattery} * 60 * 1000))
          fi

          # Skip if auto-suspend disabled
          [ "$THRESHOLD_MS" -eq 0 ] && exit 0

          echo "Idle check: idle=''${IDLE_MS}ms, threshold=''${THRESHOLD_MS}ms, battery=$ON_BATTERY" | \
            ${pkgs.systemd}/bin/systemd-cat -t auto-suspend -p info

          if [ "$IDLE_MS" -ge "$THRESHOLD_MS" ]; then
            # Show notification
            ${pkgs.libnotify}/bin/notify-send \
              --urgency=critical \
              "Auto-Suspend" \
              "System will suspend in 30 seconds due to inactivity" 2>/dev/null || true

            sleep 30

            # Re-check idle time to avoid suspending if user became active
            IDLE_MS_RECHECK=$(${pkgs.systemd}/bin/busctl --user call \
              org.gnome.Mutter.IdleMonitor \
              /org/gnome/Mutter/IdleMonitor/Core \
              org.gnome.Mutter.IdleMonitor \
              GetIdletime 2>/dev/null | awk '{print $2}')

            # If still idle, force suspend
            if [ -n "$IDLE_MS_RECHECK" ] && [[ "$IDLE_MS_RECHECK" =~ ^[0-9]+$ ]] && [ "$IDLE_MS_RECHECK" -ge "$THRESHOLD_MS" ]; then
              echo "Suspending (idle: ''${IDLE_MS_RECHECK}ms >= threshold: ''${THRESHOLD_MS}ms)" | \
                ${pkgs.systemd}/bin/systemd-cat -t auto-suspend -p info
              ${pkgs.systemd}/bin/systemctl suspend -i 2>/dev/null || true
            fi
          fi
        '';
      };

      systemd.user.timers.auto-suspend-idle-check = {
        description = "Periodic idle time check for auto-suspend";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "${toString cfg.checkIntervalMinutes}min";
          OnUnitActiveSec = "${toString cfg.checkIntervalMinutes}min";
        };
      };

      # Allow user to suspend without authentication (required for auto-suspend to work)
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.login1.suspend" ||
              action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
              action.id == "org.freedesktop.login1.suspend-ignore-inhibit") {
            if (subject.isInGroup("wheel")) {
              return polkit.Result.YES;
            }
          }
        });
      '';
    })

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
