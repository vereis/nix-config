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
      # my dwm config requires dmenu
      # for which rofi is a replacement of
      environment.systemPackages = with pkgs; [
        rofi
      ];

      # Grab my custom dwm build
      nixpkgs.overlays = [
        (self: super: {
          dwm = super.dwm.overrideAttrs(_: {
            src = builtins.fetchGit {
              url = "https://github.com/vereis/dwm";
              rev = "b247aeb8e713ac5c644c404fa1384e05e0b8bc6f";
              ref = "master";
            };
          });
        })
      ];

      services.xserver.enable = true;
      services.xserver.windowManager.dwm.enable = true;
      services.xserver.displayManager.sessionCommands = ''
        xsetroot --solid "#222222"
      '';
    }]);
  }
