{
  config,
  lib,
  pkgs,
  zjstatus,
  ...
}:

with lib;
let
  vetspireFrontend = pkgs.writeShellScriptBin "frontend" ''
    direnv allow .. >/dev/null 2>&1 || true
    exec direnv exec .. bash -c 'yarn && yarn gql && yarn start'
  '';

  vetspireApi = pkgs.writeShellScriptBin "api" ''
    direnv allow .. >/dev/null 2>&1 || true
    exec direnv exec .. bash -c '
      if ! docker ps --format "{{.Names}}" | grep -qx vetspire-postgres; then
        docker-compose up -d db
      fi
      mix deps.get && mix do ecto.create, ecto.migrate, vetspire.seed && iex -S mix phx.server
    '
  '';
in
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
        vetspireFrontend
        vetspireApi
      ];

      file = {
        ".config/television/cable/sessions.toml".source = ./tv/zellij-session/remote.toml;

        ".local/bin/zellij-session-switcher" = {
          executable = true;
          source = ./tv/zellij-session/actions.sh;
        };

        ".config/zellij/config.kdl".text = ''
          default_shell "nu"
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

          keybinds {
            shared_except "tmux" "locked" {
              unbind "Ctrl b"
              bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
              bind "Alt j" "Alt Down" { MoveFocus "Down"; }
              bind "Alt k" "Alt Up" { MoveFocus "Up"; }
              bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
              bind "Alt n" { NewPane; }
            }

            normal {
              unbind "Ctrl o"
              unbind "Ctrl n"
              unbind "Ctrl g"
              unbind "Ctrl p"
              unbind "Ctrl t"
              bind "Ctrl b" { SwitchToMode "Tmux"; }
              bind "Alt H" "Alt Shift Left" { NewPane "Right"; MovePane "Left"; }
              bind "Alt J" "Alt Shift Down" { NewPane "Down"; }
              bind "Alt K" "Alt Shift Up" { NewPane "Down"; MovePane "Up"; }
              bind "Alt L" "Alt Shift Right" { NewPane "Right"; }
              bind "Alt n" { NewPane; }
              bind "Alt t" { NewTab; }
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt 6" { GoToTab 6; }
              bind "Alt 7" { GoToTab 7; }
              bind "Alt 8" { GoToTab 8; }
              bind "Alt 9" { GoToTab 9; }
              bind "Alt 0" { GoToTab 10; }
              bind "Alt q" { CloseFocus; }
              bind "Alt f" { ToggleFloatingPanes; }
              bind "Alt F" { TogglePaneEmbedOrFloating; }
              bind "Alt z" { ToggleFocusFullscreen; }
              bind "Alt g" "Alt G" {
                Run "${config.home.homeDirectory}/.local/bin/git-branch-switcher" "pick" {
                  name "Branches"
                  floating true
                  borderless true
                  close_on_exit true
                  x "10%"
                  y "8%"
                  width "80%"
                  height "84%"
                }
              }
              bind "Alt s" "Alt S" {
                Run "${config.home.homeDirectory}/.local/bin/zellij-session-switcher" "pick" {
                  floating true
                  borderless true
                  close_on_exit true
                  x "20%"
                  y "12%"
                  width "60%"
                  height "76%"
                }
              }
              bind "Alt [" { MoveTab "Left"; }
              bind "Alt ]" { MoveTab "Right"; }
              bind "Alt ;" { NextSwapLayout; }
              bind "Alt r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            }

            tmux {
              bind "[" { SwitchToMode "Scroll"; }
              bind "r" { SwitchToMode "Resize"; }
              bind "/" "?" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Esc" "q" { SwitchToMode "Normal"; }
              bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
            }

            resize {
              bind "h" { Resize "Increase Left"; }
              bind "j" { Resize "Increase Down"; }
              bind "k" { Resize "Increase Up"; }
              bind "l" { Resize "Increase Right"; }
              bind "Left" { Resize "Increase Left"; }
              bind "Down" { Resize "Increase Down"; }
              bind "Up" { Resize "Increase Up"; }
              bind "Right" { Resize "Increase Right"; }
              bind "Shift Left" { MovePane "Left"; }
              bind "Shift Down" { MovePane "Down"; }
              bind "Shift Up" { MovePane "Up"; }
              bind "Shift Right" { MovePane "Right"; }
              bind "H" { MovePane "Left"; }
              bind "J" { MovePane "Down"; }
              bind "K" { MovePane "Up"; }
              bind "L" { MovePane "Right"; }
              bind "=" "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "Esc" "Enter" "q" { SwitchToMode "Normal"; }
              bind "Ctrl b" { SwitchToMode "Tmux"; }
            }

            scroll {
              bind "e" { EditScrollback; SwitchToMode "Normal"; }
              bind "/" "?" { SwitchToMode "EnterSearch"; SearchInput 0; }
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

            entersearch {
              bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
            }

            search {
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" { PageScrollDown; }
              bind "Ctrl b" "PageUp" { PageScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "n" "/" { Search "down"; }
              bind "N" "?" { Search "up"; }
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "w" { SearchToggleOption "Wrap"; }
              bind "o" { SearchToggleOption "WholeWord"; }
              bind "Esc" "q" { ScrollToBottom; SwitchToMode "Normal"; }
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

              frame_unselected {
                base 33 32 46
                background 25 23 36
                emphasis_0 33 32 46
                emphasis_1 33 32 46
                emphasis_2 33 32 46
                emphasis_3 33 32 46
              }

              frame_selected {
                base 64 61 82
                background 25 23 36
                emphasis_0 64 61 82
                emphasis_1 64 61 82
                emphasis_2 64 61 82
                emphasis_3 64 61 82
              }

              frame_highlight {
                base 33 32 46
                background 25 23 36
                emphasis_0 33 32 46
                emphasis_1 33 32 46
                emphasis_2 33 32 46
                emphasis_3 33 32 46
              }
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
                  format_right "{datetime} #[bg=#ebbcba,fg=#191724,bold] {session} {mode}"
                  format_space ""

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  tab_normal         "#[bg=#9090aa,fg=#191724] {name} #[fg=#403d52] "
                  tab_active         "#[bg=#dedef4,fg=#191724,italic] {name} #[fg=#403d52] "
                  mode_normal        ""
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

            tab

            swap_tiled_layout name="vertical" {
              tab max_panes=5 {
                pane split_direction="vertical" {
                  pane
                  pane { children; }
                }
              }
              tab max_panes=8 {
                pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
                }
              }
              tab max_panes=12 {
                pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
                  pane { pane; pane; pane; pane; }
                }
              }
            }

            swap_tiled_layout name="horizontal" {
              tab max_panes=5 {
                pane
                pane
              }
              tab max_panes=8 {
                pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                }
              }
              tab max_panes=12 {
                pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                }
              }
            }

            swap_tiled_layout name="stacked" {
              tab min_panes=5 {
                pane split_direction="vertical" {
                  pane
                  pane stacked=true { children; }
                }
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

        ".config/zellij/layouts/workspace.kdl".text = ''
          layout borderless=true {
            pane split_direction="vertical" {
              pane command="bash" size="50%" {
                focus true
                args "-lc" "direnv allow . >/dev/null 2>&1 || true; direnv exec . nvim; exec direnv exec . nu"
              }
              pane split_direction="horizontal" {
                pane command="bash" {
                  args "-lc" "direnv allow . >/dev/null 2>&1 || true; direnv exec . opencode; exec direnv exec . nu"
                }
                pane command="bash" size="28%" {
                  args "-lc" "direnv allow . >/dev/null 2>&1 || true; exec direnv exec . nu"
                }
              }
            }

            pane size=1 borderless=true {
              plugin location="file:${
                zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/zjstatus.wasm" {
                format_left  "{tabs}"
                format_right "{datetime} #[bg=#ebbcba,fg=#191724,bold] {session} {mode}"
                format_space ""

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=#6C7086]{char}"
                border_position "top"

                tab_normal         "#[bg=#9090aa,fg=#191724] {name} #[fg=#403d52] "
                tab_active         "#[bg=#dedef4,fg=#191724,italic] {name} #[fg=#403d52] "
                mode_normal        ""
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
        '';

        ".config/zellij/layouts/vetspire.kdl".text = ''
          layout borderless=true {
            pane split_direction="vertical" {
              pane command="bash" size="50%" {
                focus true
                args "-lc" "direnv allow . >/dev/null 2>&1 || true; direnv exec . nvim; exec direnv exec . nu"
              }
              pane split_direction="horizontal" {
                pane command="bash" {
                  args "-lc" "direnv allow . >/dev/null 2>&1 || true; direnv exec . opencode; exec direnv exec . nu"
                }
                pane command="bash" size="28%" {
                  args "-lc" "direnv allow . >/dev/null 2>&1 || true; exec direnv exec . nu"
                }
              }
            }

            floating_panes {
              pane command="frontend" name="web" cwd="web" start_suspended=true {
                x "56%"
                y "35%"
                width "42%"
                height "30%"
              }
              pane command="api" name="api" cwd="api" start_suspended=true {
                x "56%"
                y "65%"
                width "42%"
                height "35%"
              }
            }

            pane size=1 borderless=true {
              plugin location="file:${
                zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/zjstatus.wasm" {
                format_left  "{tabs}"
                format_right "{datetime} #[bg=#ebbcba,fg=#191724,bold] {session} {mode}"
                format_space ""

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=#6C7086]{char}"
                border_position "top"

                tab_normal         "#[bg=#9090aa,fg=#191724] {name} #[fg=#403d52] "
                tab_active         "#[bg=#dedef4,fg=#191724,italic] {name} #[fg=#403d52] "
                mode_normal        ""
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
        '';
      };
    };

    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      exitShellOnExit = true;
    };
  };
}
