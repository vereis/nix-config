{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.vmware_guest;
  in
  {
    options.modules.vmware_guest = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables configuration tweaks if host is running in VMware
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      virtualisation.vmware.guest.enable = true;
    }]);
  }
