{
  config,
  lib,
  pkgs,
  zjstatus,
  ...
}:

with lib;
{
  options.modules.zellij = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.modules.zellij.enable {
    home = {
      packages = with pkgs; [
        zellij
        zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      file = {
        ".config/zellij/config.kdl".text = ''
          default_shell "fish"
          default_layout "default";
          on_force_close "quit"
          copy_on_select true;

          theme "rose-pine";
          simplified_ui true;
          pane_frames false;
          ui {
            pane_frames {
              hide_session_name true
            }
          }

          keybinds clear-defaults=true {
            normal {
              bind "Ctrl b" { SwitchToMode "Tmux"; }
              bind "Alt h" "Alt Left" { MoveFocus "Left"; }
              bind "Alt j" "Alt Down" { MoveFocus "Down"; }
              bind "Alt k" "Alt Up" { MoveFocus "Up"; }
              bind "Alt l" "Alt Right" { MoveFocus "Right"; }
            }

            tmux {
              bind "c" { NewTab; SwitchToMode "Normal"; }
              bind "x" { CloseFocus; SwitchToMode "Normal"; }
              bind "X" { CloseTab; SwitchToMode "Normal"; }
              bind "n" { GoToNextTab; SwitchToMode "Normal"; }
              bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind ";" { ToggleTab; SwitchToMode "Normal"; }
              bind "0" { GoToTab 10; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "9" { GoToTab 9; SwitchToMode "Normal"; }

              bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "|" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "Enter" { NewPane; SwitchToMode "Normal"; }

              bind "h" "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "j" "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "l" "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "o" { FocusNextPane; SwitchToMode "Normal"; }

              bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

              bind "d" { Detach; }

              bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }
              bind "w" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
              bind "F" { TogglePaneFrames; SwitchToMode "Normal"; }
              bind "i" { TogglePanePinned; SwitchToMode "Normal"; }

              bind "s" { NewPane "Down"; MovePane "Down"; SwitchToMode "Normal"; }

              bind "e" { EditScrollback; SwitchToMode "Normal"; }

              bind "S" {
                LaunchOrFocusPlugin "session-manager" {
                  floating true
                  move_to_focused_tab true
                };
                SwitchToMode "Normal";
              }

              bind "b" { BreakPane; SwitchToMode "Normal"; }
              bind "}" { BreakPaneRight; SwitchToMode "Normal"; }
              bind "{" { BreakPaneLeft; SwitchToMode "Normal"; }

              bind "," { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "." { SwitchToMode "RenamePane"; PaneNameInput 0; }

              bind "[" { SwitchToMode "Scroll"; }

              bind "r" { SwitchToMode "Resize"; }
              bind "m" { SwitchToMode "Move"; }

              bind "Space" { NextSwapLayout; SwitchToMode "Normal"; }

              bind "y" { ToggleActiveSyncTab; SwitchToMode "Normal"; }

              bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }

              bind "Esc" "q" { SwitchToMode "Normal"; }
            }

            resize {
              bind "h" "Left" { Resize "Increase Left"; }
              bind "j" "Down" { Resize "Increase Down"; }
              bind "k" "Up" { Resize "Increase Up"; }
              bind "l" "Right" { Resize "Increase Right"; }
              bind "H" { Resize "Decrease Left"; }
              bind "J" { Resize "Decrease Down"; }
              bind "K" { Resize "Decrease Up"; }
              bind "L" { Resize "Decrease Right"; }
              bind "=" "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "Esc" "Enter" "q" { SwitchToMode "Normal"; }
              bind "Ctrl b" { SwitchToMode "Tmux"; }
            }

            move {
              bind "n" "Tab" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "h" "Left" { MovePane "Left"; }
              bind "j" "Down" { MovePane "Down"; }
              bind "k" "Up" { MovePane "Up"; }
              bind "l" "Right" { MovePane "Right"; }
              bind "Esc" "Enter" "q" { SwitchToMode "Normal"; }
              bind "Ctrl b" { SwitchToMode "Tmux"; }
            }

            scroll {
              bind "e" { EditScrollback; SwitchToMode "Normal"; }
              bind "s" "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" { PageScrollDown; }
              bind "Ctrl b" "PageUp" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "g" { ScrollToTop; }
              bind "G" { ScrollToBottom; }
              bind "Esc" "q" { ScrollToBottom; SwitchToMode "Normal"; }
            }

            search {
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" { PageScrollDown; }
              bind "Ctrl b" "PageUp" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "n" { Search "down"; }
              bind "N" "p" { Search "up"; }
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "w" { SearchToggleOption "Wrap"; }
              bind "o" { SearchToggleOption "WholeWord"; }
              bind "Esc" "q" { ScrollToBottom; SwitchToMode "Normal"; }
            }

            entersearch {
              bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
            }

            renametab {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
            }

            renamepane {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenamePane; SwitchToMode "Normal"; }
              bind "Enter" { SwitchToMode "Normal"; }
            }
          }
        '';

        ".config/zellij/themes/rose-pine.kdl".text = ''
          themes {
            rose-pine {
              bg "#191724"
              fg "#e0def4"
              red "#eb6f92"
              green "#31748f"
              blue "#9ccfd8"
              yellow "#f6c177"
              magenta "#c4a7e7"
              orange "#fe640b"
              cyan "#ebbcba"
              black "#26233a"
              white "#e0def4"
            }
          }
        '';

        ".config/zellij/layouts/default.kdl".text = ''
          layout borderless=true {
            default_tab_template {
              children
              pane size=1 borderless=true {
                plugin location="file:${
                  zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
                }/bin/zjstatus.wasm" {
                  format_left  "{tabs}"
                  format_right "{datetime} {mode}"
                  format_space ""

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  tab_normal         "#[bg=#9090aa,fg=#191724] {name} #[fg=#403d52] "
                  tab_active         "#[bg=#dedef4,fg=#191724,italic] {name} #[fg=#403d52] "
                  mode_normal        "#[bg=#ebbcba,fg=#191724,bold] Normal "
                  mode_locked        "#[bg=#ebbcba,fg=#191724,bold] Locked "
                  mode_resize        "#[bg=#ebbcba,fg=#191724,bold] Resize "
                  mode_pane          "#[bg=#ebbcba,fg=#191724,bold] Pane "
                  mode_tab           "#[bg=#ebbcba,fg=#191724,bold] Tab "
                  mode_scroll        "#[bg=#ebbcba,fg=#191724,bold] Scroll "
                  mode_enter_search  "#[bg=#ebbcba,fg=#191724,bold] Enter Search "
                  mode_search        "#[bg=#ebbcba,fg=#191724,bold] Search "
                  mode_rename_tab    "#[bg=#ebbcba,fg=#191724,bold] Rename Tab "
                  mode_rename_pane   "#[bg=#ebbcba,fg=#191724,bold] Rename Pane "
                  mode_session       "#[bg=#ebbcba,fg=#191724,bold] Session "
                  mode_move          "#[bg=#ebbcba,fg=#191724,bold] Move "
                  mode_prompt        "#[bg=#ebbcba,fg=#191724,bold] Prompt "
                  mode_tmux          "#[bg=#ebbcba,fg=#191724,bold] Tmux "

                  datetime        "#[fg=#6C7086] {format} "
                  datetime_format "%b %d %Y %l:%M %p"
                  datetime_timezone "Europe/London"
                }
              }
            }

            tab_template name="ui" {
              children
              pane size=1 borderless=true {
                plugin location="file:${
                  zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
                }/bin/zjstatus.wasm" {
                  format_left  "{tabs}"
                  format_right "{datetime} {mode}"
                  format_space ""

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  tab_normal         "#[bg=#1C1C1C,fg=#403d52] {name} #[fg=#403d52]"
                  tab_active         "#[bg=#9ccfd8,fg=#191724,italic] {name} #[fg=#403d52]"
                  mode_normal        "#[bg=#ebbcba,fg=#191724,bold] NORMAL "
                  mode_locked        "#[bg=#ebbcba,fg=#191724,bold] LOCKED "
                  mode_resize        "#[bg=#ebbcba,fg=#191724,bold] RESIZE "
                  mode_pane          "#[bg=#ebbcba,fg=#191724,bold] PANE "
                  mode_tab           "#[bg=#ebbcba,fg=#191724,bold] TAB "
                  mode_scroll        "#[bg=#ebbcba,fg=#191724,bold] SCROLL "
                  mode_enter_search  "#[bg=#ebbcba,fg=#191724,bold] ENTER SEARCH "
                  mode_search        "#[bg=#ebbcba,fg=#191724,bold] SEARCH "
                  mode_rename_tab    "#[bg=#ebbcba,fg=#191724,bold] RENAME TAB "
                  mode_rename_pane   "#[bg=#ebbcba,fg=#191724,bold] RENAME PANE "
                  mode_session       "#[bg=#ebbcba,fg=#191724,bold] SESSION "
                  mode_move          "#[bg=#ebbcba,fg=#191724,bold] MOVE "
                  mode_prompt        "#[bg=#ebbcba,fg=#191724,bold] PROMPT "
                  mode_tmux          "#[bg=#ebbcba,fg=#191724,bold] TMUX "

                  datetime        "#[fg=#6C7086] {format} "
                  datetime_format "%b %d %Y %l:%M %p"
                  datetime_timezone "Europe/London"
                }
              }
            }

            tab

            swap_tiled_layout name="vertical" {
              ui max_panes=5 {
                pane split_direction="vertical" {
                  pane
                  pane { children; }
                }
              }
              ui max_panes=8 {
                pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
                }
              }
              ui max_panes=12 {
                pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
                  pane { pane; pane; pane; pane; }
                }
              }
            }

            swap_tiled_layout name="horizontal" {
              ui max_panes=5 {
                pane
                pane
              }
              ui max_panes=8 {
                pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                }
              }
              ui max_panes=12 {
                pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                }
              }
            }

            swap_tiled_layout name="stacked" {
              ui min_panes=5 {
                pane split_direction="vertical" {
                  pane
                  pane stacked=true { children; }
                }
              }
            }

            swap_floating_layout name="overlay" {
              floating_panes max_panes=5 {
                pane { x "100%"; y "80%"; width "60%"; height "20%"; }
                pane { x "100%"; y "60%"; width "60%"; height "20%"; }
                pane { x "100%"; y "40%"; width "60%"; height "20%"; }
                pane { x "100%"; y "20%"; width "60%"; height "20%"; }
              }
            }

            swap_floating_layout name="staggered" {
              floating_panes
            }

            swap_floating_layout name="enlarged" {
              floating_panes max_panes=10 {
                pane { x "5%"; y 1; width "90%"; height "90%"; }
                pane { x "5%"; y 2; width "90%"; height "90%"; }
                pane { x "5%"; y 3; width "90%"; height "90%"; }
                pane { x "5%"; y 4; width "90%"; height "90%"; }
                pane { x "5%"; y 5; width "90%"; height "90%"; }
                pane { x "5%"; y 6; width "90%"; height "90%"; }
                pane { x "5%"; y 7; width "90%"; height "90%"; }
                pane { x "5%"; y 8; width "90%"; height "90%"; }
                pane { x "5%"; y 9; width "90%"; height "90%"; }
                pane focus=true { x 10; y 10; width "90%"; height "90%"; }
              }
            }

            swap_floating_layout name="spread" {
              floating_panes max_panes=1 {
                pane {y "50%"; x "50%"; }
              }
              floating_panes max_panes=2 {
                pane { x "1%"; y "25%"; width "45%"; }
                pane { x "50%"; y "25%"; width "45%"; }
              }
              floating_panes max_panes=3 {
                pane focus=true { y "55%"; width "45%"; height "45%"; }
                pane { x "1%"; y "1%"; width "45%"; }
                pane { x "50%"; y "1%"; width "45%"; }
              }
              floating_panes max_panes=4 {
                pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                pane focus=true { x "50%"; y "55%"; width "45%"; height "45%"; }
                pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                pane { x "50%"; y "1%"; width "45%"; height "45%"; }
              }
            }
          }
        '';
      };
    };

    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      exitShellOnExit = true;
    };
  };
}
