{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.hhkb = {
    enable = mkOption   { type = types.bool; default = false; };
  };

  config = mkIf config.modules.hhkb.enable {
    environment.systemPackages = with pkgs; [ xorg.xmodmap ];
    services.xserver.displayManager.sessionCommands =
      "${pkgs.xorg.xmodmap}/bin/xmodmap '${pkgs.writeText "xkb-layout" ''
      ! Map HHKB's henkan keys to super
      keysym Muhenkan = Super_L
      keysym Henkan_Mode = Super_R
      ''}'";
  };
}
