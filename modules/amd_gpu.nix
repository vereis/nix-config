{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.amd_gpu;
  in
  {
    options.modules.amd_gpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables amd gpu settings
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      boot.kernelPackages = pkgs.linuxPackages_latest;
      hardware.enableRedistributableFirmware = true;
      hardware.opengl.enable = true;
      services.xserver.videoDrivers = [ "amdgpu" ];
    }]);
  }
