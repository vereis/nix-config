{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.dwm;
  in
  {
    options.modules.dwm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables custom dwm overlay settings
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      # Grab my custom dwm build
      nixpkgs.overlays = [
        (self: super: {
          dwm = super.dwm.overrideAttrs(_: {
            src = builtins.fetchGit {
              url = "https://github.com/vereis/dwm";
              rev = "101300dc26467cb9c474dde946655ad68528ae35";
              ref = "master";
            };
          });
        })
      ];

      services.xserver.enable = true;
      services.xserver.windowManager.dwm.enable = true;
    }]);
  }
