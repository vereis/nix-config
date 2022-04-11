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
      "alt+enter" = "toggle_fullscreen";

      "ctrl+equal" = "change_font_size current +1.0";
      "ctrl+minus" = "change_font_size current -1.0";

      "alt+shift+enter" = "new_window";
      "alt+shift+space" = "next_layout";
      "alt+shift+z" = "toggle_layout stack";
      "alt+shift+r" = "start_resizing_window";
      "alt+shift+w" = "close_window";
      "alt+h" = "prev_window";
      "alt+l" = "next_window";
      "alt+shift+h" = "move_window_backward";
      "alt+shift+l" = "move_window_forward";

      "ctrl+shift+t" = "new_tab";
      "ctrl+tab" = "next_tab";
      "ctrl+shift+w" = "close_tab";
    };

    programs.kitty.settings = {
      font_family      = "FantasqueSansMono";
      bold_font        = "FantasqueSansMono-Regular";
      bold_italic_font = "FantasqueSansMono-Italic";

      font_size = 11;

      window_padding_width = 14;

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

      linux_display_server = "x11";
    };

    home.sessionVariables = mkIf (config.globals.isWsl) {
      DEFAULT_TERMINAL = "kitty";
    };
  };
}
