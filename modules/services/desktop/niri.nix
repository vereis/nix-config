{
  pkgs,
  lib,
  config,
  username,
  inputs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    types
    literalExpression
    range
    ;
  cfg = config.modules.services.desktop.niri;

  # TODO: Consolidate colors into a shared theme module that works for both
  # home-manager and NixOS configurations (similar to how niri.nix is structured)
  colors = {
    accent = {
      blue = "#7DD3FC";
      pink = "#FF69B4";
    };
    bg = {
      primary = "#060606";
      secondary = "#222222";
      selection = "#1a1a1a";
      overview = "#191724";
      dim = "rgba(0, 0, 0, 0.5)";
    };
    fg = {
      primary = "#e0def4";
      muted = "#6e6a86";
    };
  };

  fonts = {
    mono = "Maple Mono NF";
    size = 12;
  };

  timing = {
    monitorOffSec = 300;
    suspendSec = 600;
    notificationMs = 30000;
    animationSpeed = 0.6;
  };

  appearance = {
    unfocusedOpacity = 0.8;
    borderWidth = 1;
    walkerWidth = 1200;
  };

  activeGradient = {
    from = colors.accent.blue;
    to = colors.accent.pink;
    angle = 45;
    relative-to = "workspace-view";
  };

  screenshotScript = pkgs.writeShellScript "screenshot" (
    builtins.readFile (
      pkgs.replaceVars ./scripts/screenshot.sh {
        grim = "${pkgs.grim}/bin/grim";
        slurp = "${pkgs.slurp}/bin/slurp";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        notify-send = "${pkgs.libnotify}/bin/notify-send";
      }
    )
  );

  recordScript = pkgs.writeShellScript "record" (
    builtins.readFile (
      pkgs.replaceVars ./scripts/record.sh {
        slurp = "${pkgs.slurp}/bin/slurp";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wf-recorder = "${pkgs.wf-recorder}/bin/wf-recorder";
        notify-send = "${pkgs.libnotify}/bin/notify-send";
        makoctl = "${pkgs.mako}/bin/makoctl";
      }
    )
  );

  walkerItemLayout = builtins.readFile ./niri/walker/item.xml;

  wallpaperScript = pkgs.writeShellScript "wallpaper" (
    builtins.readFile (
      pkgs.replaceVars ./scripts/wallpaper.sh {
        swww = "${pkgs.swww}/bin/swww";
        swaybg = "${pkgs.swaybg}/bin/swaybg";
      }
    )
  );

  walkerThemeCss =
    builtins.replaceStrings
      [
        "@BG_PRIMARY@"
        "@FG_PRIMARY@"
        "@ACCENT_BLUE@"
        "@ACCENT_PINK@"
        "@BG_SELECTION@"
        "@FG_MUTED@"
        "@BG_DIM@"
        "@FONT_MONO@"
        "@FONT_SIZE@"
        "@BORDER_WIDTH@"
      ]
      [
        colors.bg.primary
        colors.fg.primary
        colors.accent.blue
        colors.accent.pink
        colors.bg.selection
        colors.fg.muted
        colors.bg.dim
        fonts.mono
        (toString fonts.size)
        (toString appearance.borderWidth)
      ]
      (builtins.readFile ./niri/walker/theme.css);
in
{
  options.modules.services.desktop.niri = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable niri scrollable-tiling Wayland compositor.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to include beyond the defaults.";
    };

    outputs = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = ''
        Output (display) configuration. This is the only host-specific setting.

        To configure outputs (resolution, refresh rate, scaling):
          - Find output names: `niri msg outputs`
          - See available modes: listed under "Available modes" in output
          - Example: outputs."DP-2" = { mode = { width = 3840; height = 2160; refresh = 143.982; }; scale = 1.0; };
      '';
      example = literalExpression ''
        {
          "DP-2" = {
            mode = { width = 3840; height = 2160; refresh = 143.982; };
            scale = 1.0;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;

    services = {
      xserver.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      displayManager.autoLogin = mkIf config.modules.services.desktop.autoLogin {
        enable = true;
        user = username;
      };
    };

    programs.xwayland.enable = true;

    environment.systemPackages =
      with pkgs;
      [
        # Power Management
        swayidle
        sway-audio-idle-inhibit

        # Screen Recording
        grim
        slurp
        wf-recorder

        # Clipboard & Input
        wl-clipboard
        wtype

        # Wallpaper
        swaybg
        swww

        # Applications
        nautilus
        bibata-cursors
        xwayland-satellite
        ghostty
        libnotify

        # Audio & Brightness
        wireplumber
        brightnessctl
        pavucontrol
      ]
      ++ cfg.extraPackages;

    environment.variables = {
      NIXOS_OZONE_WL = "1";
    };

    home-manager.sharedModules = [
      inputs.walker.homeManagerModules.default
      {
        programs = {
          elephant = {
            enable = true;
            provider = {
              desktopapplications.settings = {
                launch_prefix = "";
              };
              symbols.settings = {
                locale = "en";
                command = "sh -c 'wl-copy %VALUE% && sleep 0.1 && wtype -M ctrl v -m ctrl'";
              };
              websearch.settings = {
                always_show_default = false;
                entries = [
                  {
                    default = true;
                    name = "Kagi";
                    url = "https://kagi.com/search?q=%TERM%";
                  }
                  {
                    name = "Gemini 3 Flash";
                    prefix = "hey";
                    url = "https://t3.chat/new?model=gemini-3-flash&q=%TERM%";
                  }
                ];
              };
              bluetooth.settings = {
                prefix = "bt";
              };
            };
          };

          niri.settings = {
            inherit (cfg) outputs;

            spawn-at-startup = [
              # HACK: Import environment variables into systemd user session for apps launched via dbus/Walker
              {
                command = [
                  "sh"
                  "-c"
                  "source /etc/set-environment && systemctl --user import-environment PATH NIX_LD NIX_LD_LIBRARY_PATH WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
                ];
              }
              { command = [ "xwayland-satellite" ]; }
              { command = [ "sway-audio-idle-inhibit" ]; }
              {
                command = [
                  "swayidle"
                  "-w"
                  "timeout"
                  (toString timing.monitorOffSec)
                  "niri msg action power-off-monitors"
                  "resume"
                  "niri msg action power-on-monitors"
                  "timeout"
                  (toString timing.suspendSec)
                  "systemctl suspend"
                ];
              }
              # HACK: We use BOTH swww and swaybg intentionally:
              # - swww: displays the regular wallpaper on workspaces (namespace: swww-daemon)
              # - swaybg: displays the blurred wallpaper in the overview backdrop (namespace: wallpaper)
              # The layer-rule below places only "wallpaper" namespace surfaces in the backdrop,
              # so swww shows on workspaces while swaybg shows behind the overview.
              { command = [ "${wallpaperScript}" ]; }
            ];

            prefer-no-csd = true;

            layer-rules = [
              {
                matches = [ { namespace = "^wallpaper$"; } ];
                place-within-backdrop = true;
              }
            ];

            input = {
              keyboard.xkb = {
                layout = "us";
              };
              touchpad = {
                tap = true;
                natural-scroll = true;
              };
              mouse = {
                accel-profile = "flat";
              };
              focus-follows-mouse.enable = true;
            };

            layout = {
              gaps = 0;
              center-focused-column = "on-overflow";
              always-center-single-column = true;
              preset-column-widths = [
                { proportion = 0.33333; }
                { proportion = 0.5; }
                { proportion = 0.66667; }
              ];
              default-column-width = {
                proportion = 0.5;
              };
              focus-ring.enable = false;
              border = {
                enable = true;
                width = 0;
                active.gradient = activeGradient;
                inactive.color = colors.bg.secondary;
              };
              shadow.enable = false;
            };

            binds = {
              "Mod+Return".action.spawn = "ghostty";
              "Mod+Space".action.spawn = [
                "walker"
                "--width"
                (toString appearance.walkerWidth)
              ];
              "Mod+E".action.spawn = [
                "walker"
                "--width"
                (toString appearance.walkerWidth)
                "--provider"
                "symbols"
              ];
              "Mod+B".action.spawn = "zen";
              "Mod+Shift+E".action.quit = { };
              "Mod+Q".action.close-window = { };
              "Mod+Shift+Q".action.spawn = [
                "sh"
                "-c"
                "kill -9 $(niri msg --json focused-window | jq -r '.pid')"
              ];

              "Mod+Left".action.focus-column-left = { };
              "Mod+Right".action.focus-column-right = { };
              "Mod+Up".action.focus-window-up = { };
              "Mod+Down".action.focus-window-down = { };
              "Mod+H".action.focus-column-left = { };
              "Mod+L".action.focus-column-right = { };
              "Mod+K".action.focus-window-up = { };
              "Mod+J".action.focus-window-down = { };

              "Mod+Shift+Left".action.move-column-left = { };
              "Mod+Shift+Right".action.move-column-right = { };
              "Mod+Shift+Up".action.move-window-up = { };
              "Mod+Shift+Down".action.move-window-down = { };
              "Mod+Shift+H".action.move-column-left = { };
              "Mod+Shift+L".action.move-column-right = { };
              "Mod+Shift+K".action.move-window-up = { };
              "Mod+Shift+J".action.move-window-down = { };

              "Mod+Comma".action.consume-window-into-column = { };
              "Mod+Period".action.expel-window-from-column = { };

              "Mod+R".action.switch-preset-column-width = { };
              "Mod+F".action.maximize-column = { };
              "Mod+Shift+F".action.fullscreen-window = { };

              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";

              "Mod+Page_Down".action.focus-workspace-down = { };
              "Mod+Page_Up".action.focus-workspace-up = { };
              "Mod+Shift+Page_Down".action.move-column-to-workspace-down = { };
              "Mod+Shift+Page_Up".action.move-column-to-workspace-up = { };

              "Mod+S".action.spawn = [ "${screenshotScript}" ];
              "Mod+Shift+S".action.spawn = [
                "${screenshotScript}"
                "region"
              ];
              "Mod+V".action.spawn = [ "${recordScript}" ];
              "Mod+Shift+V".action.spawn = [
                "${recordScript}"
                "region"
              ];

              "Mod+Tab".action.toggle-overview = { };
              "Alt+Tab".action.focus-window-previous = { };

              "Mod+Shift+Space".action.spawn = [
                "sh"
                "-c"
                "niri msg action toggle-window-floating && sleep 0.05 && niri msg action set-column-width 50%"
              ];
              "Mod+C".action.center-column = { };

              "Mod+T".action.toggle-column-tabbed-display = { };

              "Mod+WheelScrollDown".action.focus-workspace-down = { };
              "Mod+WheelScrollUp".action.focus-workspace-up = { };
              "Mod+WheelScrollRight".action.focus-column-right = { };
              "Mod+WheelScrollLeft".action.focus-column-left = { };

              "XF86AudioRaiseVolume".action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%+"
              ];
              "XF86AudioLowerVolume".action.spawn = [
                "wpctl"
                "set-volume"
                "@DEFAULT_AUDIO_SINK@"
                "5%-"
              ];
              "XF86AudioMute".action.spawn = [
                "wpctl"
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "toggle"
              ];
              "XF86MonBrightnessUp".action.spawn = [
                "brightnessctl"
                "set"
                "5%+"
              ];
              "XF86MonBrightnessDown".action.spawn = [
                "brightnessctl"
                "set"
                "5%-"
              ];
            }
            // (builtins.listToAttrs (
              builtins.concatMap (n: [
                {
                  name = "Mod+${toString n}";
                  value = {
                    action.focus-workspace = n;
                  };
                }
                {
                  name = "Mod+Shift+${toString n}";
                  value = {
                    action.move-column-to-workspace = n;
                  };
                }
              ]) (range 1 9)
            ));

            animations = {
              slowdown = timing.animationSpeed;
            };

            overview = {
              backdrop-color = colors.bg.overview;
            };

            window-rules = [
              {
                matches = [ { is-focused = false; } ];
                opacity = appearance.unfocusedOpacity;
                draw-border-with-background = true;
              }
              # NOTE: Multiple adjacent ghostty columns make it hard to differentiate where one window
              # begins/ends, so we add a subtle border to help distinguish between terminals
              {
                matches = [ { app-id = "^com\\.mitchellh\\.ghostty$"; } ];
                border = {
                  enable = true;
                  width = appearance.borderWidth;
                  active.color = colors.bg.secondary;
                  inactive.color = colors.bg.secondary;
                };
              }
              {
                matches = [ { is-floating = true; } ];
                border = {
                  enable = true;
                  width = appearance.borderWidth;
                  active.gradient = activeGradient;
                  inactive.color = colors.bg.secondary;
                };
                shadow.enable = true;
                default-column-width = {
                  proportion = 0.5;
                };
              }
            ];

            screenshot-path = "$HOME/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png";
          };

          walker = {
            enable = true;
            runAsService = true;
            config = {
              theme = "niri";
              list.max_entries = 10;
              search.placeholder = "Search...";
              hide_action_hints = true;
              hide_quick_activation = true;
            };
            themes.niri = {
              layouts = {
                item = walkerItemLayout;
                item_desktopapplications = walkerItemLayout;
                item_files = walkerItemLayout;
                item_websearch = walkerItemLayout;
                item_calc = walkerItemLayout;
                item_runner = walkerItemLayout;
                item_clipboard = walkerItemLayout;
              };
              style = walkerThemeCss;
            };
          };
        };

        home.pointerCursor = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk.enable = true;
        };

        gtk = {
          enable = true;
          gtk4.extraConfig = {
            gtk-cursor-blink = false;
          };
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            cursor-blink = false;
          };
        };

        services.mako = {
          enable = true;
          settings = {
            background-color = colors.bg.primary;
            text-color = colors.fg.primary;
            border-color = colors.accent.blue;
            border-size = appearance.borderWidth;
            font = "${fonts.mono} ${toString fonts.size}";
            width = 400;
            height = 150;
            margin = "20";
            padding = "15";
            border-radius = 0;
            icons = 0;
            default-timeout = timing.notificationMs;
          };
          extraConfig = ''
            [urgency=high]
            border-color=${colors.accent.pink}
          '';
        };
      }
    ];
  };
}
