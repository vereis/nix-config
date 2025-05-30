{ pkgs, ... }:

{
  imports = [
    ../../../modules/services/printing.nix
    ../../../modules/services/tailscale.nix
  ];

  modules.tailscale.enable = true;
}
