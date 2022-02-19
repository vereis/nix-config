{ config, lib, pkgs, ... }:

with lib;
{
  options.hardware.x11 = {
    enable = mkOption { type = types.bool; default = false; };
    dpi = mkOption { type = types.int; default = 100; };
    layout = mkOption { type = types.str; default = "us"; };
  };

  config = mkIf config.hardware.x11.enable {
    services.xserver.enable = true;
    services.xserver.autorun = true;

    # TODO: skip login entirely; my setups usually only have one user.
    #       possibly look into just having encrypted drive instead.
    services.xserver.displayManager.lightdm.enable = true;

    # I want to minimize how much of my setup is managed by `NixOS`,
    # instead, opting to do as much via `home-manager` as possible.
    #
    # As a result, don't set a default xsession (since that would
    # not mesh with relying solely on `home-manager` modules),
    # instead: look for user xsession file instead which can be
    # managed by `home-manager` :-)
    services.xserver.displayManager.session = [
      {
        manage = "desktop";
        name = "xsession";
        start = "exec $HOME/.xsession";
      }
    ];

    services.xserver.dpi = config.hardware.x11.dpi;
    hardware.video.hidpi.enable = config.hardware.x11.dpi > 100;

    services.xserver.layout = config.hardware.x11.layout;
  };
}
