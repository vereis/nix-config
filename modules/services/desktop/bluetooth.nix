{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.modules.services.desktop.bluetooth;
in
{
  options.modules.services.desktop.bluetooth = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Bluetooth support with Blueman GUI and TUI manager.";
    };

    powerOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Power on Bluetooth controller on boot.";
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      inherit cfg.powerOnBoot;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
      bluez # Bluetooth protocol stack
      gum # Required by bluetooth-manager TUI script
    ];
  };
}
