{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.lorri;
  in
  {
    options.modules.lorri = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables lorri (and direnv)
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      services.lorri.enable = true;

      home-manager.users.chris.home.packages = with pkgs; [
        pkgs.direnv
      ];
      
      # Add whatever lorri/direnv hook stuff below
      home-manager.users.chris.programs.zsh.initExtra = ''
        if type direnv > /dev/null; then
          eval "$(direnv hook zsh)"
        fi
      '';
    }]);
  }
