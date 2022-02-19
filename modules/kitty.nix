{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.kitty = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.kitty.enable {
    home.packages = with pkgs; [ pkgs.kitty pkgs.fantasque-sans-mono ]; 

    programs.kitty.enable = true;

    programs.kitty.keybindings = {
      "ctrl+equal" = "change_font_size current +1.0";
      "ctrl+minus" = "change_font_size current -1.0";
    };

    programs.kitty.settings = {
      font_family = "FantasqueSansMono";
      font_size = 15;

      window_padding_width = 20;

      copy_on_select = "clipboard";
      enable_audio_bell = false;
   
      background = "#080808";
      foreground = "#bbbbbb";
      cursor     = "#bbbbbb";
      color0     = "#121212";
      color8     = "#545454";
      color1     = "#fa2573";
      color9     = "#f5669c";
      color2     = "#97e123";
      color10    = "#b0e05e";
      color3     = "#dfd460";
      color11    = "#fef26c";
      color4     = "#0f7fcf";
      color12    = "#00afff";
      color5     = "#8700ff";
      color13    = "#af87ff";
      color6     = "#42a7cf";
      color14    = "#50cdfe";
      color7     = "#bbbbbb";
      color15    = "#ffffff";
      selection_foreground = "#121212";
      selection_background = "#b4d5ff";

      adjust_line_height = "2";
    };    

    home.sessionVariables = mkIf (config.globals.isWsl) {
      DEFAULT_TERMINAL = "kitty";
    };
  };
}
