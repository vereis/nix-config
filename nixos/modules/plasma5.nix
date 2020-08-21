{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.plasma5;
  in
  {
    options.modules.plasma5 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables KDE
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      services.xserver.enable = true;
      services.xserver.desktopManager.plasma5.enable = true;
    }]);
  }
