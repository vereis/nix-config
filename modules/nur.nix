{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.nur;
  in
  {
    options.modules.nur = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable third party packages via NUR
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      nixpkgs.config.packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    }]);
  }
