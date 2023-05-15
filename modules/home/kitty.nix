{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.kitty = {
    enable   = mkOption { type = types.bool; default = false; };
    fontSize = mkOption { type = types.int;  default = 11; };
  };

  config = mkIf config.modules.kitty.enable {
    home = {
      packages = with pkgs; [ kitty nerdfonts ];
      sessionVariables.DEFAULT_TERMINAL = "kitty";
    };

    programs.kitty = {
      enable = true;

      keybindings = {
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

      settings = {
        # Fonts
        font_size = config.modules.kitty.fontSize;
        font_family = "FantasqueSansMono Nerd Font Mono";
        adjust_line_height = "2";

        # Padding
        window_padding_width = config.modules.kitty.fontSize + 3;

        # Behaviour
        copy_on_select = "clipboard";
        enable_audio_bell = false;
        linux_display_server = "x11";
        sync_to_monitor = "no";

        # Transparency
        background_opacity = "0.875";
        dynamic_background_opacity = "yes";

        # Colors / Theming
        foreground              = "#CDD6F4";
        background              = "#030303";
        selection_foreground    = "#1E1E2E";
        selection_background    = "#F5E0DC";
        cursor                  = "#F5E0DC";
        cursor_text_color       = "#1E1E2E";
        color0                  = "#45475A"; # Black
        color8                  = "#585B70"; # Black
        color1                  = "#F38BA8"; # Red
        color9                  = "#F38BA8"; # Red
        color2                  = "#A6E3A1"; # Green
        color10                 = "#A6E3A1"; # Green
        color3                  = "#F9E2AF"; # Yellow
        color11                 = "#F9E2AF"; # Yellow
        color4                  = "#89B4FA"; # Blue
        color12                 = "#89B4FA"; # Blue
        color5                  = "#F5C2E7"; # Magenta
        color13                 = "#F5C2E7"; # Magenta
        color6                  = "#94E2D5"; # Cyan
        color14                 = "#94E2D5"; # Cyan
        color7                  = "#BAC2DE"; # White
        color15                 = "#A6ADC8"; # White
        mark1_foreground        = "#1E1E2E";
        mark1_background        = "#B4BEFE";
        mark2_foreground        = "#1E1E2E";
        mark2_background        = "#CBA6F7";
        mark3_foreground        = "#1E1E2E";
        mark3_background        = "#74C7EC";
        active_tab_foreground   = "#11111B";
        active_tab_background   = "#CBA6F7";
        inactive_tab_foreground = "#CDD6F4";
        inactive_tab_background = "#181825";
        inactive_text_alpha     = "0.35";
        tab_bar_style           = "powerline";
      };
    };
  };
}
