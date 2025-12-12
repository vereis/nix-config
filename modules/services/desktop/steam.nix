{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
let
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

  config = mkIf config.modules.services.desktop.steam.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = isWayland;
      remotePlay.openFirewall = config.modules.services.desktop.steam.remotePlay;
      dedicatedServer.openFirewall = false;
      
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamemode = mkIf config.modules.services.desktop.steam.gamemode {
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

    environment.systemPackages = with pkgs;
      optionals isWayland [ gamescope ];

    hardware.steam-hardware.enable = true;
  };
}
