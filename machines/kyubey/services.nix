{ pkgs, ... }:

{
  imports = [
    ../../modules/services/transmission.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/sonarr.nix
    ../../modules/services/readarr.nix
    ../../modules/services/radarr.nix
    ../../modules/services/lidarr.nix
    ../../modules/services/prowlarr.nix
    ../../modules/services/flaresolverr.nix
    ../../modules/services/proxy.nix
    ../../modules/services/printing.nix
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

  modules.readarr.enable = true;
  modules.readarr.openFirewall = true;

  modules.lidarr.enable = true;
  modules.lidarr.openFirewall = true;

  modules.prowlarr.enable = true;
  modules.prowlarr.openFirewall = true;

  modules.flareSolverr.enable = true;
  modules.flareSolverr.openFirewall = true;

  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.tailscale.openFirewall = true;

  modules.proxy.enable = true;
  modules.proxy.openFirewall = true;
  modules.proxy.proxies = {
    "jellyfin.vereis.com" = 8096;
    "sonarr.vereis.com" = 8989;
    "radarr.vereis.com" = 7878;
    "prowlarr.vereis.com" = 9696;
    "transmission.vereis.com" = 9091;
    "lidarr.vereis.com" = 8686;
    "readarr.vereis.com" = 8787;
    "printer.vereis.com" = 631;
  };

  modules.printing.enable = true;
  modules.printing.wifi = true;
}
