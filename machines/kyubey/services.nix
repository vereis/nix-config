{ pkgs, ... }:

{
  imports = [
    ../../modules/services/tailscale.nix
    ../../modules/services/jellyfin.nix
  ];

  modules.jellyfin.enable = true;
  modules.jellyfin.nvidiaVaapi  = true;
  modules.jellyfin.openFirewall = true;
  modules.jellyfin.jellyseerr.enable = true;

  modules.tailscale.enable = true;
  modules.tailscale.openFirewall = true;
}
