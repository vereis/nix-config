{ pkgs, ... }:

{
  imports = [
    ../../../modules/services/printing.nix
    ../../../modules/services/tailscale.nix
  ];

  modules.printing.enable = true;
  modules.tailscale.enable = true;
}
