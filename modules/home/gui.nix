{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.modules.gui = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enables and configures Wayland, Hyprland, and other GUI applications.";
    };

    wallpapers = mkOption {
      type = types.listOf types.str;
      default = [ "~/.wallpaper" ];
      description = "Path to wallpaper image files.";
    };

    scale = mkOption {
      type = types.number;
      default = 1;
      description = "Scale factor for HiDPI displays.";
    };

    font.name = mkOption {
      type = types.str;
      default = "Tamzen";
      description = "Primary font name for GUI applications.";
    };

    font.secondary = mkOption {
      type = types.str;
      default = "Fantasque Sans Mono";
      description = "Secondary font name for GUI applications (used for font switching).";
    };

    font.size = mkOption {
      type = types.int;
      default = 11;
      description = "Default font size for GUI applications.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install for GUI applications.";
    };

    customScripts = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Custom scripts to added to `/usr/bin` for quick launch.";
    };
  };

  config = mkIf config.modules.gui.enable {
    home.packages =
      with pkgs;
      [
        hyprland
        hypridle
        hyprlock
        hyprpaper
        wezterm
        pavucontrol
        tamzen
        wl-clipboard
        wl-clipboard-x11
        tofi
        mako
        libnotify
        jq
        grim
        slurp
        wf-recorder
        fantasque-sans-mono
        (qutebrowser.override { enableWideVine = true; })
      ]
      ++ config.modules.gui.extraPackages
      ++ builtins.attrValues (
        builtins.mapAttrs (
          name: path: (writeShellScriptBin name (builtins.readFile path))
        ) config.modules.gui.customScripts
      );

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      font = {
        inherit (config.modules.gui.font) name;
        inherit (config.modules.gui.font) size;
      };
    };

    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    programs.tofi = {
      enable = true;
      settings = {
        width = "100%";
        height = "100%";
        border-width = 0;
        outline-width = 0;
        padding-left = "45%";
        padding-top = "45%";
        result-spacing = 2;
        num-results = 10;
        font = "${config.modules.gui.font.name}";
        font-size = config.modules.gui.font.size + 1;
        matching-algorithm = "fuzzy";
        background-color = "#000A";
        text-color = "#e0def4";
        selection-color = "#f6c177";
      };
    };

    # TODO: port to home-manager config when available
    home.file.".config/mako/config" = {
      text = ''
        sort=-time
        layer=overlay
        height=128
        width=412
        margin=16
        outer-margin=24
        padding=24
        border-size=2
        border-radius=0
        icons=0
        default-timeout=10000
        actions=true
        anchor=bottom-right
        background-color=#060606
        font=${config.modules.gui.font.name} ${toString (config.modules.gui.font.size + 1)}
        border-color=#524f67

        [urgency=low]
        border-color=#31748f

        [urgency=normal]
        border-color=#524f67

        [urgency=high]
        border-color=#eb6f92

        [category=custom]
        border-color=#9ccfd8
        anchor=top-right
      '';
    };

    programs.qutebrowser = {
      enable = true;
      package = pkgs.qutebrowser.override { enableWideVine = true; };
      enableDefaultBindings = true;
      settings = {
        colors = {
          tabs = {
            bar.bg = "#060606";
            even.bg = "#060606";
            odd.bg = "#060606";
            even.fg = "#908caa";
            odd.fg = "#908caa";
            selected.even.bg = "#0f0f0f";
            selected.odd.bg = "#0f0f0f";
            selected.even.fg = "#e0def4";
            selected.odd.fg = "#e0def4";
          };

          statusbar = {
            normal.bg = "#060606";
            normal.fg = "#908caa";
            passthrough.bg = "#d7827e";
            insert.bg = "#060606";
            private.bg = "#907aa9";
            url = {
              fg = "#e0def4";
              error.fg = "#eb6f92";
              hover.fg = "#c4a7e7";
              success.http.fg = "#e0def4";
              success.https.fg = "#31748f";
              warn.fg = "#f6c177";
            };
          };

          completion = {
            fg = "#908caa";
            even.bg = "#060606";
            odd.bg = "#060606";
            match.fg = "#f6c177";

            category = {
              bg = "#060606";
              fg = "#9ccfd8";
              border = {
                top = "#060606";
                bottom = "#060606";
              };
            };

            item.selected = {
              bg = "#0f0f0f";
              fg = "#e0def4";
              match.fg = "#f6c177";

              border = {
                top = "#0f0f0f";
                bottom = "#0f0f0f";
              };
            };

            scrollbar = {
              bg = "#21202e";
              fg = "#524f67";
            };
          };
        };

        tabs = {
          favicons.show = "never";
          position = "left";
          width = 256;
          indicator.width = 0;
        };

        fonts = {
          default_family = config.modules.gui.font.name;
          default_size = "${toString (config.modules.gui.font.size + 1)}pt";
        };

        content = {
          pdfjs = true; # Just view PDFs instead of downloading them first
          notifications.enabled = false;
          javascript.clipboard = "access";
        };

        completion = {
          use_best_match = true;
          shrink = true;
        };

        downloads = {
          remove_finished = 10000;
          position = "bottom";

          location = {
            prompt = false;
            suggestion = "filename";
            directory = "~/downloads";
          };
        };

        editor.command = [
          "wezterm"
          "-e"
          "nvim"
          "{file}"
        ];
      };
      extraConfig = ''
        c.tabs.padding = {'top': 15, 'bottom': 16, 'left': 16, 'right': 16}
        c.statusbar.padding = {'top': 15, 'bottom': 16, 'left': 16, 'right': 16}
        c.url.start_pages = "https://kagi.com/"
        c.url.searchengines = {
          'DEFAULT': 'https://kagi.com/search?q={}',
          '!a': 'https://www.amazon.co.uk/s?k={}',
          '!ex': 'https://hexdocs.pm/elixir/search.html?q={}',
          '!oban': 'https://hexdocs.pm/oban/search.html?q={}',
          '!ecto': 'https://hexdocs.pm/ecto/search.html?q={}',
          '!gh': 'https://github.com/search?o=desc&q={}&s=stars',
          '!gist': 'https://gist.github.com/search?q={}',
          '!g': 'https://www.google.com/search?q={}',
          '!gi': 'https://www.google.com/search?tbm=isch&q={}&tbs=imgo:1',
          '!gm': 'https://www.google.com/maps/search/{}',
          '!r': 'https://www.reddit.com/search?q={}',
          '!w': 'https://en.wikipedia.org/wiki/{}',
          '!yt': 'https://www.youtube.com/results?search_query={}'
        }
      '';
    };

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      BROWSER = "qutebrowser";
      DEFAULT_BROWSER = "qutebrowser";
    };

    home.file.".local/bin/hyprland/toggle-floating" = {
      executable = true;
      source = ./gui/toggle-floating;
    };

    home.file.".local/bin/hyprland/screenrecord" = {
      executable = true;
      source = ./gui/screenrecord;
    };

    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      extraConfig = ''
        local wezterm = require('wezterm')
        local act = wezterm.action

        local deshou = wezterm.color.get_builtin_schemes()['rose-pine'];
        deshou.background = '#060606';

        local function toggle_font(window, pane)
          local overrides = window:get_config_overrides() or {}

          -- Track current font state using a custom key
          local is_secondary_font = overrides.font_is_secondary or false
          local new_font

          if is_secondary_font then
            new_font = wezterm.font_with_fallback({'${config.modules.gui.font.name}', 'Material Icons'})
            overrides.font_is_secondary = false
          else
            new_font = wezterm.font_with_fallback({'${config.modules.gui.font.secondary}', 'Material Icons'})
            overrides.font_is_secondary = true
          end

          overrides.font = new_font
          window:set_config_overrides(overrides)
        end

        local config = {
          enable_tab_bar = false;
          enable_scroll_bar = false;
          default_cursor_style = 'BlinkingBlock';
          animation_fps = 1;
          cursor_blink_ease_in = 'Constant';
          cursor_blink_ease_out = 'Constant';
          allow_square_glyphs_to_overflow_width = 'Never';
          font = wezterm.font_with_fallback({
            '${config.modules.gui.font.name}',
            'Material Icons'
          });

          window_padding = {
            left = 32;
            right = 32;
            top = 32;
            bottom = 32;
          };

          color_schemes = {
            ['deshou'] = deshou
          };

          color_scheme = 'deshou';

          keys = {
            {
              key = 'f',
              mods = 'CTRL|SHIFT',
              action = wezterm.action_callback(toggle_font),
            },
          };
        }

        return config
      '';
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = config.modules.gui.wallpapers;
        wallpaper = builtins.map (wp: ", ${wp}") config.modules.gui.wallpapers;
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.variables = [ "--all" ];
      settings = {
        "$mod" = "SUPER";

        env = [
          "QT_WAYLAND_DISABLE_WINDOWDECORATIONS,1"
          "QT_QPA_PLATFORM,wayland"
          "GDK_SCALE,1"
          "XCURSOR_SIZE,16"
        ];

        exec = [
          "hyprctl keyword windowrulev2 \"size 1280 720, class:.*\""
        ];

        exec-once = [
          "hyprctl setcursor Bibata-Modern-Classic 16"
          "mako"
        ];

        xwayland = {
          force_zero_scaling = true;
        };

        # For all monitors, choose the highest refresh rate possible
        monitor = ", highrr, auto, ${toString config.modules.gui.scale}";

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "ALT, mouse:272, movewindow"
          "ALT, mouse:273, resizewindow"
        ];

        # Basic Bindings
        bind = [
          # Functional
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          "$mod, E, exec, wezterm -e lf"
          "$mod, T, exec, sh $HOME/.local/bin/hyprland/toggle-floating"
          "$mod, R, resizeactive"
          "$mod, SPACE, exec, tofi-run | xargs hyprctl dispatch exec --"
          "$mod, C, exec, notify-send \"Currently - $(date '+%Y-%m-%d %H:%M:%S')\" --category=custom"

          # Launchers
          "$mod, RETURN, exec, wezterm"
          "$mod, W, exec, qutebrowser"

          # Navigation
          "$mod, J, layoutmsg, cyclenext"
          "$mod, J, alterzorder, top"
          "$mod, K, layoutmsg, cycleprev"
          "$mod, K, alterzorder, top"
          "$mod, LEFT, movefocus, l"
          "$mod, LEFT, alterzorder, top"
          "$mod, RIGHT, movefocus, r"
          "$mod, RIGHT, alterzorder, top"
          "$mod, UP, movefocus, u"
          "$mod, UP, alterzorder, top"
          "$mod, DOWN, movefocus, d"
          "$mod, DOWN, alterzorder, top"

          # Window management
          "$mod SHIFT, J, layoutmsg, swapnext"
          "$mod SHIFT, K, layoutmsg, swapprev"

          # Screen Capture
          "$mod SHIFT, S, exec, slurp | grim -g - - | wl-copy"
          "$mod SHIFT, V, exec, sh $HOME/.local/bin/hyprland/screenrecord"
        ]
        ++ (
          # workspaces
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          )
        );

        general = {
          snap = {
            enabled = true;
            window_gap = 32;
            monitor_gap = 32;
            border_overlap = true;
          };

          border_size = 2;
          gaps_in = -1; # When tiling, adjacent windows will share a border
          gaps_out = -2; # When tiling, borders touching the monitor edge will be removed
          layout = "master";
          allow_tearing = true;
          resize_on_border = true;
          hover_icon_on_border = true;
          extend_border_grab_area = 32;
          "col.active_border" = "rgb(191724)";
          "col.inactive_border" = "rgb(191724)";
        };

        master = {
          mfact = 0.5;
          new_status = "master";
          new_on_top = true;
          inherit_fullscreen = false;
        };

        decoration = {
          rounding = 0;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          fullscreen_opacity = 1.0;
          dim_inactive = true;
          dim_strength = 0.25;

          blur = {
            enabled = false;
          };

          shadow = {
            enabled = false;
            range = 32;
          };
        };

        animations = {
          enabled = true;
          first_launch_animation = false;
        };

        animation = [
          "windows, 0"
          "layers, 0"
          "border, 0"
          "borderangle, 0"
          "fadeIn, 0"
          "fadeOut, 0"
          "fadeSwitch, 0"
          "fadeShadow, 0"
          "fadeLayers, 0"
        ];

        input = {
          repeat_delay = 500;
          repeat_rate = 50;
          accel_profile = "flat";
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          background_color = "rgb(217, 191, 194)";
        };

        cursor = {
          sync_gsettings_theme = true;
        };
      };
    };
  };
}
