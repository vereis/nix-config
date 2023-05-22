{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.prowlarr = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.prowlarr.enable {
    services.prowlarr = {
      enable = true;
      openFirewall = config.modules.prowlarr.openFirewall;
    };
  };
}
