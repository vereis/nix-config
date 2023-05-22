{ pkgs, ... }:

{
  imports = [
    ../../modules/services/transmission.nix
    ../../modules/services/tailscale.nix
    ../../modules/services/jellyfin.nix
    ../../modules/services/sonarr.nix
    ../../modules/services/radarr.nix
  ];

  modules.transmission.enable = true;
  modules.transmission.openFirewall = true;

  modules.jellyfin.enable = true;
  modules.jellyfin.nvidiaVaapi  = true;
  modules.jellyfin.openFirewall = true;
  modules.jellyfin.jellyseerr.enable = true;

  modules.sonarr.enable = true;
  modules.sonarr.openFirewall = true;

  modules.radarr.enable = true;
  modules.radarr.openFirewall = true;

  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.tailscale.openFirewall = true;
}
