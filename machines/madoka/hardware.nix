{ pkgs, ... }:

{
  imports = [
    ../../modules/hardware/hhkb.nix
  ];

  modules.hhkb.enable = true;
}
