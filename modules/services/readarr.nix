{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.readarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.readarr.enable {
    services.readarr = {
      enable = true;
      openFirewall = config.modules.readarr.openFirewall;
    };
  };
}
