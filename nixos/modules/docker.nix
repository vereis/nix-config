{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.docker;
  in
  {
    options.modules.docker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables docker and docker compose
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      virtualisation.docker.enable = true;
      virtualisation.docker.enableOnBoot = true;

      home-manager.users.chris.home.packages = with pkgs; [
        pkgs.docker-compose
      ];
    }]);
  }
