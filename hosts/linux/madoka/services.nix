{ ... }:

{
  imports = [
    ../../../modules/services/tailscale.nix
  ];

  modules = {
    tailscale.enable = true;
  };
}
