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
  cfg = config.modules.services.desktop.capture;

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
        gdbus = "${pkgs.glib}/bin/gdbus";
        pgrep = "${pkgs.procps}/bin/pgrep";
      }
    )
  );
in
{
  options.modules.services.desktop.capture = {
    screenshots = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Wayland screenshot tool (grim + slurp).";
      };
    };
    recordings = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Wayland screen recording tool (wf-recorder).";
      };
    };
  };

  config = mkMerge [
    # Screenshots configuration
    (mkIf cfg.screenshots.enable {
      environment.systemPackages = with pkgs; [
        grim # Screenshot tool for Wayland
        slurp # Region selection for Wayland
        wl-clipboard # Clipboard utilities
        libnotify # notify-send for notifications
      ];

      environment.etc."capture/screenshot.sh" = {
        source = screenshotScript;
        mode = "0755";
      };
    })

    # Recordings configuration
    (mkIf cfg.recordings.enable {
      environment.systemPackages = with pkgs; [
        wf-recorder # Screen recording for Wayland
        slurp # Region selection for Wayland
        wl-clipboard # Clipboard utilities
        libnotify # notify-send for notifications
        # Note: mako is optional (only for niri), glib provides gdbus for GNOME
        mako # Provides makoctl for niri notification dismissal
        glib # Provides gdbus for GNOME notification dismissal
        procps # Provides pgrep for desktop detection
      ];

      environment.etc."capture/record.sh" = {
        source = recordScript;
        mode = "0755";
      };
    })
  ];
}
