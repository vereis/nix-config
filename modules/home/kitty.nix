{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.kitty = {
    enable = mkOption { type = types.bool; default = false; };
    fontSize = mkOption { type = types.int; default = 11; };
  };

  config = mkIf config.modules.kitty.enable {
    home = {
      packages = with pkgs; [
        kitty
        nerdfonts
        (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
      ];

      sessionVariables.DEFAULT_TERMINAL = "kitty";
    };

    programs.kitty = {
      enable = true;

      keybindings = {
        "cmd+enter" = "no_op";
        "cmd+f" = "no_op";
        "cmd+q" = "close_tab";
        "ctrl+equal" = "change_font_size current +1.0";
        "ctrl+minus" = "change_font_size current -1.0";
      };

      settings = (mkMerge [
        # Set up some generic settings
        {
          # Fonts
          font_size = config.modules.kitty.fontSize;
          font_family = lib.mkDefault "FantasqueSansMono Nerd Font Mono";

          adjust_line_height = "2";

          # Padding
          window_padding_width = config.modules.kitty.fontSize + 3;

          # Behaviour
          copy_on_select = "clipboard";
          enable_audio_bell = false;
          linux_display_server = "x11";
          sync_to_monitor = "no";
          close_on_child_death = "yes";
          hide_window_decorations = "no";
          confirm_os_window_close = -1;

          # Transparency
          background_blur = 32;
          background_opacity = "0.825";
          dynamic_background_opacity = "yes";

          # Cursor
          cursor_shape = "block";
          cursor_blink_interval = -1;

          # Colors / Theming
          tab_bar_style = "powerline";
          foreground = "#e0def4";
          background = "#020203";
          selection_foreground = "#e0def4";
          selection_background = "#403d52";
          cursor = "#524f67";
          cursor_text_color = "#e0def4";
          url_color = "#c4a7e7";
          active_tab_foreground = "#e0def4";
          active_tab_background = "#26233a";
          inactive_tab_foreground = "#6e6a86";
          inactive_tab_background = "#191724";
          active_border_color = "#31748f";
          inactive_border_color = "#403d52";
          color0 = "#26233a";
          color8 = "#6e6a86";
          color1 = "#eb6f92";
          color9 = "#eb6f92";
          color2 = "#31748f";
          color10 = "#31748f";
          color3 = "#f6c177";
          color11 = "#f6c177";
          color4 = "#9ccfd8";
          color12 = "#9ccfd8";
          color5 = "#c4a7e7";
          color13 = "#c4a7e7";
          color6 = "#ebbcba";
          color14 = "#ebbcba";
          color7 = "#e0def4";
          color15 = "#e0def4";
        }
        # Set up some MacOS only settings
        (mkIf pkgs.stdenv.isDarwin {
          font_family = "FantasqueSansM Nerd Font Mono";
          macos_quit_when_last_window_closed = "yes";
          macos_window_resizable = "yes";
          macos_traditional_fullscreen = "no";
          macos_custom_beam_cursor = "yes";
        })
      ]);
    };
  };
}
