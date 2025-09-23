{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/gui.nix
    ../../../modules/home/tui.nix
  ];

  modules.gui.enable = true;
  modules.tui.enable = true;
}
