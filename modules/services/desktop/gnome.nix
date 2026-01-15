{
  pkgs,
  lib,
  config,
  username,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    types
    literalExpression
    foldl'
    replaceStrings
    attrNames
    ;
in
{
  options.modules.services.desktop.gnome = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable GNOME desktop environment with sane defaults (Wayland, bloat removed).";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional GNOME apps to include beyond the essential defaults (nautilus).";
    };

    extraGSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional GSettings overrides as Nix attribute set.";
      example = literalExpression ''
        {
          "org.gnome.desktop.session" = {
            idle-delay = "uint32 0";
          };
        }
      '';
    };

    altDrag = mkOption {
      type = types.bool;
      default = config.modules.services.desktop.altDrag;
      description = "Enable Alt+drag to move and resize windows (inherits from desktop.altDrag, can override).";
    };
  };

  config = mkIf config.modules.services.desktop.gnome.enable {
    # Enable unified media capture for screenshots and recordings
    modules.services.desktop.capture = {
      screenshots.enable = true;
      recordings.enable = true;
    };

    assertions = [
      {
        assertion =
          config.services.desktopManager.gnome.enable -> config.services.displayManager.gdm.wayland;
        message = "GNOME 49+ only supports Wayland. GDM Wayland must be enabled.";
      }
    ];

    services = {
      xserver.enable = true;

      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
        autoLogin = mkIf config.modules.services.desktop.autoLogin {
          enable = true;
          user = username;
        };
      };

      desktopManager.gnome = {
        enable = true;
      };

      gnome = {
        core-os-services.enable = true;
        core-shell.enable = true;
        core-apps.enable = false;
        games.enable = false;
        core-developer-tools.enable = false;
      };
    };

    # Use dconf system databases instead of GSettings overrides
    # This makes settings survive 'dconf reset' by providing system-level defaults
    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = "Bibata-Modern-Classic";
              enable-hot-corners = false;
              clock-show-weekday = true;
              enable-animations = true;
            };
            "org/gnome/desktop/interface/animations" = {
              speed = 1.5;
            };
            "org/gnome/desktop/peripherals/touchpad" = {
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
              natural-scroll = true;
              disable-while-typing = true;
              speed = 0.3;
            };
            "org/gtk/gtk4/settings/file-chooser" = {
              sort-directories-first = true;
            };
            "org/gnome/nautilus/preferences" = {
              default-folder-viewer = "list-view";
              show-hidden-files = false;
            };
            "org/gnome/mutter" = {
              edge-tiling = true;
              dynamic-workspaces = true;
              center-new-windows = true;
            };
            "org/gnome/shell" = {
              enabled-extensions = [
                "trayIconsReloaded@selfmade.pl"
                "dash-to-dock@micxgx.gmail.com"
                "Vitals@CoreCoding.com"
                "blur-my-shell@aunetx"
                "gsconnect@andyholmes.github.io"
                "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
                "hidetopbar@mathieu.bidon.ca"
                "clipboard-indicator@tudmotu.com"
              ];
            };
            "org/gnome/shell/extensions/dash-to-dock" = {
              show-trash = false;
              dock-fixed = false;
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              mouse-button-modifier =
                if config.modules.services.desktop.gnome.altDrag then "<Alt>" else "disabled";
              resize-with-right-button = config.modules.services.desktop.gnome.altDrag;
              focus-mode = "sloppy";
              auto-raise = false;
            };

            # Custom keybindings for screenshots and screen recording
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot-full/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot-region/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/recording-toggle/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/recording-region/"
              ];
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot-full" = {
              name = "Screenshot (Full)";
              command = "/etc/capture/screenshot.sh";
              binding = "<Super>s";
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screenshot-region" = {
              name = "Screenshot (Region)";
              command = "/etc/capture/screenshot.sh region";
              binding = "<Super><Shift>s";
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/recording-toggle" = {
              name = "Screen Recording (Toggle)";
              command = "/etc/capture/record.sh";
              binding = "<Super>v";
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/recording-region" = {
              name = "Screen Recording (Region)";
              command = "/etc/capture/record.sh region";
              binding = "<Super><Shift>v";
            };
          }
          // (
            let
              # Convert extraGSettings from flat schema.key format to nested format
              convertSettings =
                attrs:
                foldl' (
                  acc: schema:
                  acc
                  // {
                    ${replaceStrings [ "." ] [ "/" ] schema} = attrs.${schema};
                  }
                ) { } (attrNames attrs);
            in
            if config.modules.services.desktop.gnome.extraGSettings != { } then
              convertSettings config.modules.services.desktop.gnome.extraGSettings
            else
              { }
          );
        }
      ];
    };

    environment = {
      systemPackages =
        with pkgs;
        [
          adwaita-icon-theme
          nautilus
          gnome-calculator
          gnome-system-monitor
          bibata-cursors
          gnomeExtensions.tray-icons-reloaded
          gnomeExtensions.dash-to-dock
          gnomeExtensions.vitals
          gnomeExtensions.blur-my-shell
          gnomeExtensions.gsconnect
          gnomeExtensions.launch-new-instance
          gnomeExtensions.hide-top-bar
          gnomeExtensions.clipboard-indicator
        ]
        ++ config.modules.services.desktop.gnome.extraPackages;

      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-user-docs
        yelp
      ];

      variables = {
        NIXOS_OZONE_WL = "1";
      };
    };
  };
}
