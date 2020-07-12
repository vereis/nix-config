{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.intellimouse;
  in
  {
    options.modules.intellimouse = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables tweaks to make Microsoft Intellimouse more usable
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      services.xserver.exportConfiguration = true;
      services.xserver.config = ''
        Section "InputClass"
          Identifier "Microsoft Intellimouse"
          MatchIsPointer "on"

          # Disable mouse acceleration
          Option "AccelerationNumerator" "1"
          Option "AccelerationDenominator" "1"
          Option "AccelerationThreshold" "0"

          # Slow down insane base DPI
          Option "ConstantDeceleration" "7"
          Option "AdaptiveDeceleration" "7"
        EndSection
      '';
    }]);
  }
