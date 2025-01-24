{ pkgs, ... }:

{
  imports = [
    ../../../modules/services/printing.nix
  ];

  modules.printing.enable = true;
  modules.printing.wifi = true;
}
