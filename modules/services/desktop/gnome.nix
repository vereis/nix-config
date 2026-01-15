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
            };
            "org/gnome/desktop/peripherals/touchpad" = {
              tap-to-click = true;
              two-finger-scrolling-enabled = true;
              natural-scroll = true;
              disable-while-typing = true;
              speed = 0.3;
            };
            "org/gnome/mutter" = {
              edge-tiling = true;
              dynamic-workspaces = true;
              center-new-windows = true;
            };
            "org/gnome/shell" = {
              enabled-extensions = [
                "appindicatorsupport@rgcjonas.gmail.com"
                "dash-to-dock@micxgx.gmail.com"
                "Vitals@CoreCoding.com"
              ];
            };
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
              mouse-button-modifier =
                if config.modules.services.desktop.gnome.altDrag then "<Alt>" else "disabled";
              resize-with-right-button = config.modules.services.desktop.gnome.altDrag;
            };

            # Custom keybindings for screenshots and screen recording
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kooha/"
              ];
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot" = {
              name = "Flameshot Screenshot";
              command = "flameshot gui";
              binding = "<Control><Alt>s";
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kooha" = {
              name = "Kooha Screen Recording";
              command = "kooha";
              binding = "<Control><Alt>r";
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
          gnome-tweaks
          bibata-cursors
          gnomeExtensions.appindicator
          gnomeExtensions.dash-to-dock
          gnomeExtensions.vitals
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
