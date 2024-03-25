{ input, config, lib, pkgs, zjstatus, ... }:

with lib;
{
  options.modules.tmux = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.tmux.enable {
    home.packages = with pkgs; [ zellij zjstatus.packages.${system}.default ];

    home.file.".config/zellij/themes/rose-pine.kdl".text = ''
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

    home.file.".config/zellij/layouts/default.kdl".text = ''
      layout borderless=true {
        default_tab_template {
          children
          pane size=1 borderless=true {
            plugin location="file:${zjstatus.packages.${pkgs.system}.default}/bin/zjstatus.wasm" {
              format_left  "{tabs}"
              format_right "{datetime} {mode}"
              format_space ""

              border_enabled  "false"
              border_char     "─"
              border_format   "#[fg=#6C7086]{char}"
              border_position "top"

              tab_normal         "#[bg=#1C1C1C,fg=#403d52] {name} #[fg=#403d52] "
              tab_active         "#[bg=#9ccfd8,fg=#191724,italic] {name} #[fg=#403d52] "
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

        tab_template name="ui" {
          children
          pane size=1 borderless=true {
            plugin location="file:/home/chris/statusbar.wasm" {
              format_left  "{tabs}"
              format_right "{datetime} {mode}"
              format_space ""

              border_enabled  "false"
              border_char     "─"
              border_format   "#[fg=#6C7086]{char}"
              border_position "top"

              tab_normal         "#[bg=#1C1C1C,fg=#403d52] {name} #[fg=#403d52] "
              tab_active         "#[bg=#9ccfd8,fg=#191724,italic] {name} #[fg=#403d52] "
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

    home.file.".config/zellij/scripts/execute.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [[ -e ../shell.nix ]]; then
          nix-shell --command "$1" ../shell.nix
        else
          if [[ -e ./shell.nix ]]; then
            nix-shell --command "$1" ./shell.nix
          fi
        fi
      '';
    };

    home.file.".config/zellij/scripts/spawn.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [[ -e ./shell.nix ]]; then
          zellij run -f -- nix-shell --command "$1" ./shell.nix
        fi

        if [[ -e ../shell.nix ]]; then
          zellij run -f -- nix-shell --command "$1" ../shell.nix
        fi
      '';
    };

    home.file.".config/zellij/scripts/vetspire" = {
      executable = true;
      text = ''
        zellij action go-to-tab-name "Temp" -c;
        sleep .2

        # Start API
        zellij action go-to-tab-name "Vetspire (API)" -c;
        sleep .2
        zellij action close-tab
        sleep .2
        zellij action new-tab --layout "default" --cwd "/home/chris/git/vetspire/vetspire/api" --name "Vetspire (API)";
        zellij action go-to-tab-name "Vetspire (API)";
        sleep .2
        zellij run -f -c --cwd "/home/chris/git/vetspire/vetspire/api" -- /home/chris/.config/zellij/scripts/execute.sh "docker-compose up -d"
        sleep .5
        zellij run -f --cwd "/home/chris/git/vetspire/vetspire/api" -- /home/chris/.config/zellij/scripts/execute.sh "mix deps.get && mix ecto.migrate && iex -S mix phx.server"
        sleep .2
        zellij run -s -f --cwd "/home/chris/git/vetspire/vetspire/api" -- /home/chris/.config/zellij/scripts/execute.sh "mix deps.get && mix test"
        sleep .2
        zellij run -s -f --cwd "/home/chris/git/vetspire/vetspire/api" -- /home/chris/.config/zellij/scripts/execute.sh "mix deps.get && mix do credo, dialyzer && mix format --check-formatted"

        # Start Web
        zellij action go-to-tab-name "Vetspire (Web)" -c;
        sleep .2
        zellij action close-tab
        zellij action new-tab --layout "default" --cwd "/home/chris/git/vetspire/vetspire/web" --name "Vetspire (Web)";
        zellij action go-to-tab-name "Vetspire (Web)";
        sleep .2
        zellij run -f --cwd "/home/chris/git/vetspire/vetspire/web" -- /home/chris/.config/zellij/scripts/execute.sh "yarn && yarn start"

        # Start Monorepo
        zellij action go-to-tab-name "Vetspire (Git)" -c;
        sleep .2
        zellij action close-tab
        zellij action new-tab --layout "default" --cwd "/home/chris/git/vetspire/vetspire" --name "Vetspire (Git)";

        # Restore View in API
        zellij action go-to-tab-name "Temp";
        sleep .2
        zellij action close-tab
        sleep .2
        zellij action go-to-tab-name "Vetspire (API)";
        sleep .2
        zellij action move-focus down
      '';
    };

    home.file.".config/zellij/config.kdl".text = ''
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
        unbind "Ctrl o";
        normal {
          bind "Ctrl s" { SwitchToMode "Session"; }

          bind "Alt t" { NewTab; }
          bind "Alt q" { CloseFocus; }
          bind "Alt f" { ToggleFloatingPanes; }

          bind "F1" {
            Run "/home/chris/.config/zellij/scripts/execute.sh" "mix test";
            TogglePaneEmbedOrFloating;
            Run "/home/chris/.config/zellij/scripts/execute.sh" "mix do credo, dialyzer && mix format --check-formatted";
            TogglePaneEmbedOrFloating;
          }

          bind "F2" {
            Run "/home/chris/.config/zellij/scripts/execute.sh" "iex -S mix phx.server";
            TogglePaneEmbedOrFloating;
          }

          bind "F3" {
            Run "/home/chris/.config/zellij/scripts/execute.sh" "yarn && yarn start";
            TogglePaneEmbedOrFloating;
          }
        }
      }
    '';

    programs.zellij = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
