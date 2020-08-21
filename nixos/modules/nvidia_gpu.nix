{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.nvidia_gpu;
  in
  {
    options.modules.nvidia_gpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables nvidia gpu settings
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      boot.kernelPackages = pkgs.linuxPackages_latest;
      hardware.enableRedistributableFirmware = true;
      hardware.opengl.enable = true;
      services.xserver.videoDrivers = [ "nvidia" ];
    }]);
  }
