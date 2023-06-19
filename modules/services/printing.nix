{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.printing = {
    enable = mkOption { type = types.bool; default = false; };
    wifi   = mkOption { type = types.bool; default = false; };
    extraDrivers = mkOption { type = types.listOf types.package; default = []; };
  };

  config = mkIf config.modules.printing.enable {
    networking.firewall.allowedUDPPorts = mkIf config.modules.printing.wifi [ 631 ];
    networking.firewall.allowedTCPPorts = mkIf config.modules.printing.wifi [ 631 ];

    services.printing = {
      enable = true;
      browsing = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      defaultShared = true;
      drivers = [ pkgs.gutenprint pkgs.gutenprintBin ] ++ config.modules.printing.extraDrivers;
      extraConf = ''
      DefaultEncryption Never
      '';
      clientConf = ''
      DefaultEncryption Never
      '';
    };

    services.avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = config.modules.printing.wifi;
      publish.enable = true;
      publish.userServices = true;
    };
  };
}
