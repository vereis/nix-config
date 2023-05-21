{ pkgs, ... }:

{
  imports = [
    ../../modules/services/jellyfin.nix
  ];

  modules.jellyfin.enable = true;
  modules.jellyfin.nvidiaVaapi  = true;
  modules.jellyfin.openFirewall = true;
  modules.jellyfin.jellyseerr.enable = true;
}
