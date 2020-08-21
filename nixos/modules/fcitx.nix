{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.fcitx;
  in
  {
    options.modules.fcitx = {
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

      i18n.inputMethod.enabled = "fcitx";
      i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    }]);
  }
