{ pkgs, ... }:

{
  imports = [
    ../../modules/services/transmission.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/sonarr.nix
    ../../modules/services/radarr.nix
    ../../modules/services/prowlarr.nix
  ];

  modules.transmission.enable = true;
  modules.transmission.openFirewall = true;
  modules.transmission.downloadDir = "/storage/media/downloads/transmission";

  modules.jellyfin.enable = true;
  modules.jellyfin.nvidiaVaapi  = true;
  modules.jellyfin.openFirewall = true;
  modules.jellyfin.jellyseerr.enable = true;

  modules.sonarr.enable = true;
  modules.sonarr.openFirewall = true;

  modules.radarr.enable = true;
  modules.radarr.openFirewall = true;

  modules.prowlarr.enable = true;
  modules.prowlarr.openFirewall = true;

  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.tailscale.openFirewall = true;
}
