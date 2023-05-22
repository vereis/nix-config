{ pkgs, ... }:

{
  imports = [
    ../../modules/services/aria2.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/sonarr.nix
    ../../modules/services/radarr.nix
  ];

  modules.aria2.enable = true;
  modules.aria2.openFirewall = true;

  modules.jellyfin.enable = true;
  modules.jellyfin.nvidiaVaapi  = true;
  modules.jellyfin.openFirewall = true;
  modules.jellyfin.jellyseerr.enable = true;

  modules.sonarr.enable = true;
  modules.sonarr.openFirewall = true;

  modules.radarr.enable = true;
  modules.radarr.openFirewall = true;

  modules.tailscale.enable = true;
  modules.tailscale.openFirewall = true;
}
