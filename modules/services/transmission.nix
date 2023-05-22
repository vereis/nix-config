{ pkgs, lib, config, username, ... }:

with lib;
{
  options.modules.transmission = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.transmission.enable {
    environment.systemPackages = with pkgs; [ transmission transmission-gtk ];

    services.transmission = {
      enable = true;
      downloadDirPermissions = "775";

      openFirewall = config.modules.transmission.openFirewall;
      openRPCPort = config.modules.transmission.openFirewall;
      openPeerPorts = config.modules.transmission.openFirewall;
      settings = mkIf config.modules.transmission.openFirewall {
        rpc-enabled = true;
        rpc-authentication-required = true;
        rpc-username = username;
        rpc-password = "password";
        rpc-whitelist-enabled = false;
        rpc-bind-address = "0.0.0.0";
      };
    };
  };
}
