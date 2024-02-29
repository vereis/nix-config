{ pkgs, lib, nixos-wsl, username, ... }:

{
  imports = [ ./services.nix ./hardware.nix ];

  environment.systemPackages = with pkgs; [wslu];

  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.nativeSystemd = true;
  wsl.wslConf.network = {
    hostname = "madoka";
    generateResolvConf = true;
  };
  wsl.startMenuLaunchers = false;
  wsl.interop.includePath = true;

  networking.hostName = "madoka";
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];
}
