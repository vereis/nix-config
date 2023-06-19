{ pkgs, ... }:

{
  imports = [
    ../../modules/services/tailscale.nix
    ../../modules/services/printing.nix
  ];

  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.tailscale.openFirewall = true;

  modules.printing.enable = true;
  modules.printing.wifi = true;
}
