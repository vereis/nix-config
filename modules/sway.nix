{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.sway;
  in
  {
    options.modules.sway = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables sway wm
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      programs.sway.enable = true;
      programs.sway.extraPackages = with pkgs; [
        mako
        waybar
        kanshi
        xwayland
        wl-clipboard
      ];

      programs.waybar.enable = true;

      # Sway configuration
      home-manager.users.chris = {
        wayland.windowManager.sway.enable = true;
        wayland.windowManager.sway.config.terminal = "kitty";
        wayland.windowManager.sway.config.input = {
          "*" = {
            scroll_factor = "1.25";
            repeat_delay = "300";
            repeat_rate = "30";
          };
        };

        wayland.windowManager.sway.config.window.titlebar = false;
        wayland.windowManager.sway.config.window.border = 0;

        wayland.windowManager.sway.config.colors = {
          background = "#ffffff";
          focused = {
            border = "#ffffff";
            background = "#ffffff";
            childBorder = "#ffffff";
            text = "#aaaaaa";
            indicator = "#0000ff";
          };

          unfocused = {
            border = "#222222";
            background = "#222222";
            childBorder = "#222222";
            text = "#888888";
            indicator = "#0000ff";
          };

          focusedInactive = {
            border = "#222222";
            background = "#222222";
            childBorder = "#222222";
            text = "#888888";
            indicator = "#0000ff";
          };

          urgent = {
            border = "#222222";
            background = "#222222";
            childBorder = "#222222";
            text = "#888888";
            indicator = "#0000ff";
          };
        };

        wayland.windowManager.sway.config.gaps.inner = 2;
        wayland.windowManager.sway.config.gaps.outer = 0;
        wayland.windowManager.sway.config.gaps.smartGaps = true;
        wayland.windowManager.sway.config.gaps.smartBorders = "on";

        wayland.windowManager.sway.config.bars = [];
      };

      environment.variables = {
        # MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        KITTY_ENABLE_WAYLAND = "1";
      };

      # # Define custom sway start script
      # environment.systemPackages = [
      #   (
      #     pkgs.writeTextFile {
      #       name = "swayinit";
      #       destination = "/bin/swayinit";
      #       executable = true;
      #       text = ''
      #         #! ${pkgs.bash}/bin/bash
      #         systemctl --user import-environment
      #         exec systemctl --user start sway.service
      #       '';
      #     }
      #   )
      # ];

      # systemd.user.targets.sway-session = {
      #   description = "Sway composition session";
      #   documentation = [ "man:systemd.special(7)" ];
      #   bindsTo = [ "graphical-session.target" ];
      #   wants = [ "graphical-session-pre.target" ];
      #   after = [ "graphical-session-pre.target" ];
      # };

      # systemd.user.services.sway = {
      #   description = "Sway - Wayland window manager";
      #   documentation = [ "man:sway(5)" ];
      #   bindsTo = [ "graphical-session.target" ];
      #   wants = [ "graphical-session-pre.target" ];
      #   after = [ "graphical-session-pre.target" ];

      #   # Hack, swayinit sets this for us
      #   environment.PATH = lib.mkForce null;

      #   serviceConfig = {
      #     Type = "simple";
      #     ExecStart = ''
      #       ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      #     '';
      #     Restart = "on-failure";
      #     RestartSec = 1;
      #     TimeoutStopSec = 10;
      #   };
      # };

      # systemd.user.services.kanshi = {
      #   description = "Kanshi output autoconfig ";
      #   wantedBy = [ "graphical-session.target" ];
      #   partOf = [ "graphical-session.target" ];
      #   serviceConfig = {
      #     ExecStart = ''
      #     ${pkgs.kanshi}/bin/kanshi
      #     '';
      #     RestartSec = 5;
      #     Restart = "always";
      #   };
      # };
    }]);
  }
