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

    scalingFactor = mkOption {
      type = types.ints.positive;
      default = 1;
      description = "UI scaling factor (1 = 100%, 2 = 200%). Applied to both GDM and GNOME session.";
    };

    idleDelay = mkOption {
      type = types.int;
      default = 900;
      description = "Idle timeout in seconds before screen blanks (default: 900 = 15 minutes, 0 = never)";
    };
  };

  config = mkIf config.modules.services.desktop.gnome.enable {
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
          "org/gnome/desktop/interface" = {
            scaling-factor = lib.gvariant.mkUint32 config.modules.services.desktop.gnome.scalingFactor;
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
              scaling-factor = lib.gvariant.mkUint32 config.modules.services.desktop.gnome.scalingFactor;
            };
            "org/gnome/desktop/interface/animations" = {
              speed = 1.5;
            };
            "org/gnome/desktop/screensaver" = {
              lock-delay = lib.gvariant.mkUint32 0; # Disable screen lock delay
            };
            "org/gnome/desktop/session" = {
              idle-delay = lib.gvariant.mkUint32 config.modules.services.desktop.gnome.idleDelay;
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
              mouse-button-modifier = "<Super>";
              resize-with-right-button = true;
              focus-mode = "sloppy";
              auto-raise = false;
            };
            "org/gnome/mutter/keybindings" = {
              # Disable window tiling keybindings that conflict with workspace switching
              toggle-tiled-left = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
              toggle-tiled-right = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
            };
            "org/gnome/desktop/wm/keybindings" = {
              switch-to-workspace-left = [ "<Super>Left" ];
              switch-to-workspace-right = [ "<Super>Right" ];
              move-to-workspace-left = [ "<Super><Shift>Left" ];
              move-to-workspace-right = [ "<Super><Shift>Right" ];
              move-to-monitor-left = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
              move-to-monitor-right = lib.gvariant.mkEmptyArray lib.gvariant.type.string;
              close = [ "<Super>q" ];
              toggle-fullscreen = [ "<Super>f" ];
            };

            "org/gnome/shell/keybindings" = {
              show-screenshot-ui = [ "<Super>s" ];
              show-screen-recording-ui = [ "<Super>v" ];
            };

            # Custom application launcher keybindings
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
              ];
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              name = "Terminal";
              command = "ghostty";
              binding = "<Super>Return";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
              name = "Files";
              command = "nautilus";
              binding = "<Super>e";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
              name = "Browser";
              command = "zen";
              binding = "<Super>b";
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
