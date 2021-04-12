{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./base.nix
    ../modules/wslUtils.nix
  ];

  config = {
    modules.wslUtils.enable = true;
  };
}
