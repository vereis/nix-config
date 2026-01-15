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
    # GNOME uses built-in screenshot and recording (wlroots tools don't work on Mutter)
    # Screenshots: Super+S opens GNOME's screenshot UI
    # Recording: Ctrl+Shift+Alt+R for built-in recorder, or install kooha for GUI
    modules.services.desktop.capture = {
      screenshots.enable = false; # Use GNOME built-in screenshot UI
      recordings.enable = false; # Use GNOME built-in recorder or kooha
    };

    assertions = [
      {
        assertion =
          config.services.desktopManager.gnome.enable -> config.services.displayManager.gdm.wayland;
        message = "GNOME 49+ only supports Wayland. GDM Wayland must be enabled.";
      }
    ];

    # Configure GDM (login screen) scaling to match desktop
    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          # Set scaling to 1x (no scaling)
          "org/gnome/desktop/interface" = {
            scaling-factor = lib.gvariant.mkUint32 1;
          };
        };
      }
    ];

    # Copy monitor configuration to GDM so it uses same resolution/refresh rate
    systemd.tmpfiles.rules = [
      "L+ /var/lib/gdm/.config/monitors.xml - - - - /home/${username}/.config/monitors.xml"
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
              show-battery-percentage = true;
              scaling-factor = lib.gvariant.mkUint32 1; # 1x scaling (no scaling)
            };
            "org/gnome/desktop/interface/animations" = {
              speed = 1.5;
            };
            "org/gnome/desktop/screensaver" = {
              lock-delay = lib.gvariant.mkUint32 0; # Disable screen lock delay
            };
            "org/gnome/desktop/session" = {
              idle-delay = lib.gvariant.mkUint32 900; # 15 minutes
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
                "blur-my-shell@aunetx"
                "gsconnect@andyholmes.github.io"
                "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
                "hidetopbar@mathieu.bidon.ca"
              ];
            };
            "org/gnome/shell/extensions/dash-to-dock" = {
              show-trash = false;
              dock-fixed = false;
            };
            "org/gnome/shell/extensions/gsconnect" = {
              name = config.networking.hostName;
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              mouse-button-modifier =
                if config.modules.services.desktop.gnome.altDrag then "<Alt>" else "disabled";
              resize-with-right-button = config.modules.services.desktop.gnome.altDrag;
              focus-mode = "sloppy";
              auto-raise = false;
            };
            "org/gnome/desktop/wm/keybindings" = {
              switch-to-workspace-left = [ "<Super>Left" ];
              switch-to-workspace-right = [ "<Super>Right" ];
            };

            # Use GNOME's built-in screenshot and recording functionality
            # wlroots tools (grim/wf-recorder) don't work on GNOME's Mutter compositor
            "org/gnome/shell/keybindings" = {
              show-screenshot-ui = [ "<Super>s" ]; # Opens screenshot UI (region/window/screen)
              show-screen-recording-ui = [ "<Super>v" ]; # Opens screen recording UI
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
          gnomeExtensions.blur-my-shell
          gnomeExtensions.gsconnect
          gnomeExtensions.launch-new-instance
          gnomeExtensions.hide-top-bar
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
