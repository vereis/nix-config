{ pkgs, ... }:

{
  imports = [
    ../../../modules/services/gpg.nix
  ];

  modules.gpg.enable = true;
}
