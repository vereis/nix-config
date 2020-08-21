{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.i3;
  in
  {
    options.modules.i3 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables i3wm (gaps)
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      services.xserver.windowManager.i3.enable = true;
      services.xserver.windowManager.i3.package = pkgs.i3-gaps;
      services.xserver.displayManager.sessionCommands = ''
        xsetroot --solid "#222222"
      '';

      home-manager.users.chris = {
        xsession.windowManager.i3.enable = true;
        xsession.windowManager.i3.package = pkgs.i3-gaps;
        xsession.windowManager.i3.config.terminal = "kitty";

        xsession.windowManager.i3.config.window.titlebar = false;
        xsession.windowManager.i3.config.window.border = 0;

        xsession.windowManager.i3.config.gaps.inner = 2;
        xsession.windowManager.i3.config.gaps.outer = 0;
        xsession.windowManager.i3.config.gaps.smartGaps = true;
        xsession.windowManager.i3.config.gaps.smartBorders = "on";

        xsession.windowManager.i3.config.floating.titlebar = true;
        xsession.windowManager.i3.config.floating.border = 0;

        xsession.windowManager.i3.config.fonts = [ "monospace 16" ];

        xsession.windowManager.i3.config.colors = {
          focused = {
            border = "#97e023";
            background = "#97e023";
            childBorder = "#97e023";
            text = "#97e023";
            indicator = "#97e023";
          };

          unfocused = {
            border = "#161514";
            background = "#161514";
            childBorder = "#161514";
            text = "#161514";
            indicator = "#161514";
          };

          focusedInactive = {
            border = "#161514";
            background = "#161514";
            childBorder = "#161514";
            text = "#161514";
            indicator = "#161514";
          };

          urgent = {
            border = "#161514";
            background = "#161514";
            childBorder = "#161514";
            text = "#161514";
            indicator = "#161514";
          };
        };

        xsession.windowManager.i3.config.bars = [];

        xsession.windowManager.i3.extraConfig = ''
        '';
      };
    }]);
  }
