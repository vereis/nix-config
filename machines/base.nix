{ config, lib, pkgs, ... }:

with lib;
{
  options.machine = {
    turbo      = mkOption { type = types.bool; default = false; };
    uefiBoot   = mkOption { type = types.bool; default = true; };
    libinput   = mkOption { type = types.bool; default = true; };
    networking = mkOption { type = types.bool; default = true; };
    timezone   = mkOption { type = types.str; default = "Europe/London"; };
    hostName   = mkOption { type = types.str; default = ""; };
  };

  config = {
    time.timeZone = config.machine.timezone;
    networking.hostName = config.machine.hostName;

    boot.loader.systemd-boot.enable = config.machine.uefiBoot;
    boot.loader.efi.canTouchEfiVariables = config.machine.uefiBoot;

    networking.networkmanager.enable = config.machine.networking;

    services.xserver.libinput.enable = config.machine.libinput;
    services.xserver.xkbOptions = "ctrl:swapcaps";

    # It may be prudent to enable the following, but it sucks that we need to enumerate all
    # of the network interfaces to enable DHCP.
    #
    # It doesn't seem like we _need_ DHCP though... will revisit.
    #networking.useDHCP = config.machine.networking;
    #networking.interfaces.wlp0s20f3.useDHCP = true;

    # If turbo mode is set, don't throttle CPU freq
    # powerManagement.cpuFreqGovernor = mkIf (config.machine.turbo) "performance";
    # powerManagement.powertop.enable = true;
  };
}
