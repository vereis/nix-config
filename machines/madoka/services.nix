{ pkgs, ... }:

{
  imports = [
    ../../modules/services/tailscale.nix
  ];

  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.tailscale.openFirewall = true;
}
