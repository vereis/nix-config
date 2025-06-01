{ pkgs, lib, config, username, ... }:

with lib;
{
  options.modules.tailscale = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale  ];

    services.tailscale.enable = true;
    services.openssh.enable = true;

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 ];
    };
  };
}
