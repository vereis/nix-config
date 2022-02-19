{ config, lib, pkgs, ... }:

with lib;
{
  config = mkIf config.hardware.bluetooth.enable {
    environment.systemPackages = with pkgs; [ blueberry ];
    services.blueman.enable = true;
  };
}
