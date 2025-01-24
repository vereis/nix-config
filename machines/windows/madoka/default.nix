{ pkgs, lib, nixos-wsl, username, config, ... }:

{
  imports = [ ./services.nix ];

  networking.hostName = "madoka";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];

  system.stateVersion = lib.mkForce "24.05";
}
