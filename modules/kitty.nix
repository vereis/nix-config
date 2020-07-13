{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.kitty;
  in
  {
    options.modules.kitty = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables personal kitty config
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      fonts.fonts = with pkgs; [
        cascadia-code
      ];

      home-manager.users.chris.home.packages = with pkgs; [
        pkgs.kitty
      ];

      home-manager.users.chris.programs.kitty.enable = true;

      home-manager.users.chris.programs.kitty.keybindings = {
        "ctrl+equal" = "change_font_size current +1.0";
        "ctrl+minus" = "change_font_size current -1.0";
      };

      home-manager.users.chris.programs.kitty.settings = {
        font_family = "Cascadia Code PL";
        font_size = 10;

        window_padding_width = 24;

        copy_on_select = "clipboard" ;
        enable_audio_bell = false;

        # Colorscheme
        background = "#111111";
        foreground = "#c4c4b5";
        cursor = "#f6f6ec";
        selection_background = "#343434";
        color0 = "#191919";
        color8 = "#615e4b";
        color1 = "#f3005f";
        color9 = "#f3005f";
        color2 = "#97e023";
        color10 = "#97e023";
        color3 = "#fa8419";
        color11 = "#dfd561";
        color4 = "#9c64fe";
        color12 = "#9c64fe";
        color5 = "#f3005f";
        color13 = "#f3005f";
        color6 = "#57d1ea";
        color14 = "#57d1ea";
        color7 = "#c4c4b5";
        color15 = "#f6f6ee";
        selection_foreground = "#191919"; 
      };
    }]);
  }
