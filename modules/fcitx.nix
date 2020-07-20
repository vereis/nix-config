{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.fcitx;
  in
  {
    options.modules.amd_gpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables fcitx extension
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      # Install some JP fonts
      fonts.fonts = with pkgs; [
        ipafont
        kochi-substitute
      ];

      il8n.inputMethod.enabled = "fcitx";
      il8n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    }]);
  }
