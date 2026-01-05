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
    types
    optionals
    ;
  cfg = config.modules.services.desktop.steam;
  isWayland = config.services.displayManager.gdm.wayland or false;
in
{
  options.modules.services.desktop.steam = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Steam with optimal gaming configuration.";
    };

    gamemode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GameMode for automatic CPU governor and other optimizations.";
    };

    remotePlay = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Steam Remote Play.";
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = isWayland;
      remotePlay.openFirewall = cfg.remotePlay;
      dedicatedServer.openFirewall = false;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode = mkIf cfg.gamemode {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    environment.systemPackages = with pkgs; optionals isWayland [ gamescope ];

    hardware.steam-hardware.enable = true;

    # NOTE: Custom desktop entry to fix Steam not launching from Walker on first try
    home-manager.sharedModules = [
      {
        xdg.desktopEntries.steam = {
          name = "Steam";
          comment = "Application for managing and playing games on Steam";
          exec = ''bash -c "steam steam://open/games || steam"'';
          icon = "steam";
          terminal = false;
          type = "Application";
          categories = [
            "Network"
            "FileTransfer"
            "Game"
          ];
        };
      }
    ];
  };
}
