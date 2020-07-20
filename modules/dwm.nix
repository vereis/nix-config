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
              rev = "f347547089b6c9fc7602eca04d3d4a557402257f";
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


      # DWM needs it's own compositor
      home-manager.users.chris.home.packages = with pkgs; [
        pkgs.compton
      ];

      home-manager.users.chris.services.picom.enable = true;
      home-manager.users.chris.services.picom.backend = "xr_glx_hybrid";
      home-manager.users.chris.services.picom.vSync = true;
      home-manager.users.chris.services.picom.inactiveDim = "0.0";
    }]);
  }
