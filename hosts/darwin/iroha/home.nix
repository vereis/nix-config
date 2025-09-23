{
  pkgs,
  config,
  lib,
  zjstatus,
  username,
  ...
}:

{
  imports = [
    ../../../modules/home/tui.nix
  ];

  modules.tui.enable = true;
}
