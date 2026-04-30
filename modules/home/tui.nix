{
  config,
  lib,
  pkgs,
  user,
  email,
  secrets,
  ...
}:

with lib;
let
  gitSplitDiffs = pkgs.buildNpmPackage rec {
    pname = "git-split-diffs";
    version = "2.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "banga";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-3kprATuDvtXSocoVx/Fvd00z0d4nhZZZ3UqBEFmctYE=";
    };

    npmDepsHash = "sha256-mQ+JhWnBNMvHBL9T1nzIhsmMpQOTzoce5g3n3C1SrJE=";
    npmBuildScript = "build:publish";
  };
in
{
  imports = [
    ./tui/zellij.nix
  ];

  options.modules.tui = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install for TUI applications.";
    };
    extraFiles = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Extra files to create in the home directory. Accepts any valid home-manager file attributes.";
    };
    extraSessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra session variables to set. Use this for machine-specific secrets and configuration.";
    };
  };

  config = mkIf config.modules.tui.enable {
    home = {
      packages =
        with pkgs;
        [
          aria2
          bat
          btop
          cacert
          cargo
          fd
          git-absorb
          ffmpeg
          gcc
          gh
          git
          gitSplitDiffs
          httpie
          jq
          killall
          lsof
          nodejs
          nerdfetch
          opencode
          crit
          openssh
          openssl
          pciutils
          ripgrep
          rsync
          television
          tree
          unzip
          wget
          worktrunk
          zip
          gnumake
          git-crypt
          lf
          socat
          tree-sitter
          # Dependencies for lf previewer
          poppler-utils # provides pdftotext
          highlight
          unrar
          p7zip # provides 7z
        ]
        ++ config.modules.tui.extraPackages;

      file = lib.mkMerge [
        {
          ".local/bin/tv" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              export SHELL="${pkgs.bash}/bin/bash"
              exec ${pkgs.television}/bin/tv "$@"
            '';
          };
          ".local/bin/git/ssh-migrate.sh" = {
            executable = true;
            source = ./tui/git/migrate-ssh.sh;
          };
          ".local/bin/git/wt.sh" = {
            executable = true;
            source = ./tui/git/wt.sh;
          };
          ".local/bin/git-branch-switcher" = {
            executable = true;
            source = ./tui/tv/git-branch/actions.sh;
          };
          ".local/bin/zoxide-picker" = {
            executable = true;
            source = ./tui/tv/zoxide/actions.sh;
          };
          ".local/bin/npiperelay.exe" = {
            executable = true;
            source = ../../bin/npiperelay.exe;
          };
          ".config/nvim/lua/" = {
            recursive = true;
            source = ./tui/neovim/lua;
          };
          ".config/git-split-diffs/themes/vereis-dark.json" = {
            executable = false;
            source = ./tui/git/vereis-dark.json;
          };
          ".config/television/cable/branches.toml".source = ./tui/tv/git-branch/remote.toml;
          ".config/television/cable/zoxide.toml".source = ./tui/tv/zoxide/remote.toml;
          ".config/nushell/vendor/autoload/wt.nu" = {
            executable = false;
            source = pkgs.runCommand "worktrunk-nushell-integration.nu" { } ''
              ${pkgs.worktrunk}/bin/wt config shell init nu > $out
            '';
          };
          ".config/worktrunk/config.toml" = {
            executable = false;
            source = ./tui/worktrunk/config.toml;
          };
          ".gitconfig" = {
            executable = false;
            text =
              builtins.replaceStrings
                [ "EMAIL_PLACEHOLDER" "USER_PLACEHOLDER" "HOME_PLACEHOLDER" ]
                [ email user "/home/${user}" ]
                (builtins.readFile ./tui/git/.gitconfig);
          };
          ".gitconfig-vetspire" = {
            executable = false;
            text = builtins.replaceStrings [ "VETSPIRE_EMAIL_PLACEHOLDER" ] [ secrets.vetspire.gitEmail ] (
              builtins.readFile ./tui/git/.gitconfig-vetspire
            );
          };
          ".gitignore_global" = {
            executable = false;
            source = ./tui/git/.gitignore_global;
          };
          ".cc-safety-net/config.json" = {
            source = ./tui/opencode/safety-net-config.json;
          };
          ".config/opencode/" = {
            recursive = true;
            source = ./tui/opencode;
          };
          ".local/share/atuin/key" = {
            text = secrets.atuin.key;
          };
        }
        config.modules.tui.extraFiles
      ];

      sessionVariables = {
        FZF_DEFAULT_COMMAND = "rg --files";
        EDITOR = "nvim";
        VISUAL = "nvim";
        SHELL = lib.getExe config.programs.nushell.package;
      }
      // config.modules.tui.extraSessionVariables;
    };

    programs = {
      atuin = {
        enable = true;
        enableNushellIntegration = true;
        settings = {
          auto_sync = true;
          search_mode = "fuzzy";
          filter_mode = "global";
          style = "compact";
          inline_height = 20;
          show_preview = true;
        };
      };

      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableNushellIntegration = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
      };

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
        options = [
          "--cmd cd" # Use 'cd' instead of 'z'
        ];
      };

      nushell = {
        enable = true;
        environmentVariables = {
          EDITOR = "nvim";
          FZF_DEFAULT_COMMAND = "rg --files";
          SHELL = lib.getExe config.programs.nushell.package;
          VISUAL = "nvim";
        }
        // config.modules.tui.extraSessionVariables;
        settings = {
          show_banner = false;
          edit_mode = "vi";
          buffer_editor = "nvim";
        };
        extraConfig = ''
          alias z = cd
          alias zi = cdi

          def --env --wrapped git [...args] {
            if (($args | length) > 0) and (($args | first) == "wt") {
              let wt_args = ($args | skip 1)

              if (($wt_args | length) > 0) and ((($wt_args | first) == "clone") or (($wt_args | first) == "dev")) {
                ^${config.home.homeDirectory}/.local/bin/git/wt.sh ...$wt_args
              } else {
                let cd_file = (mktemp --tmpdir)
                let exec_file = (mktemp --tmpdir)
                let wt_args = if (".bare" | path exists) {
                  ["-C", ".bare"] ++ $wt_args
                } else {
                  $wt_args
                }

                let exit_code = (try {
                  with-env { WORKTRUNK_DIRECTIVE_CD_FILE: $cd_file, WORKTRUNK_DIRECTIVE_EXEC_FILE: $exec_file } {
                    ^wt ...$wt_args
                  }
                  0
                } catch {
                  $env.LAST_EXIT_CODE
                })

                if ($cd_file | path exists) and (open $cd_file --raw | str trim | is-not-empty) {
                  let worktree_path = (open $cd_file --raw | str trim)
                  cd $worktree_path
                }

                if ($exec_file | path exists) and (open $exec_file --raw | str trim | is-not-empty) {
                  ^sh -c (open $exec_file --raw)
                }

                rm -f $cd_file $exec_file

                if $exit_code != 0 {
                  ^sh -c $"exit ($exit_code)"
                }
              }
            } else {
              ^git ...$args
            }
          }

          $env.config.keybindings ++= [{
            name: edit_command_buffer
            modifier: none
            keycode: char_v
            mode: vi_normal
            event: { send: OpenEditor }
          }]

          if $nu.is-interactive and ($env.ZELLIJ? | is-empty) {
            try {
              zellij list-sessions --no-formatting
              | lines
              | where {|line| $line | str contains 'EXITED' }
              | each {|line|
                  let session_name = ($line | split row ' ' | first)
                  zellij delete-session $session_name
                }
            } catch {
            }

            zellij
            exit
          }
        '';
        shellAliases = {
          vim = "nvim";
        };
      };

      starship = {
        enable = true;
        enableNushellIntegration = true;
        settings = {
          "$schema" = "https://starship.rs/config-schema.json";
          add_newline = false;
          continuation_prompt = "[.](bright-black) ";

          character = {
            success_symbol = "[>](bold green)";
            error_symbol = "[x](bold red)";
            vimcmd_symbol = "[<](bold green)";
            vimcmd_visual_symbol = "[<](bold yellow)";
            vimcmd_replace_symbol = "[<](bold purple)";
            vimcmd_replace_one_symbol = "[<](bold purple)";
          };

          git_commit = {
            tag_symbol = " tag ";
          };

          git_status = {
            ahead = ">";
            behind = "<";
            diverged = "<>";
            renamed = "r";
            deleted = "x";
          };

          aws.symbol = "aws ";
          azure.symbol = "az ";

          battery = {
            full_symbol = "full ";
            charging_symbol = "charging ";
            discharging_symbol = "discharging ";
            unknown_symbol = "unknown ";
            empty_symbol = "empty ";
          };

          buf.symbol = "buf ";
          bun.symbol = "bun ";
          c.symbol = "C ";
          cmake.symbol = "cmake ";
          cobol.symbol = "cobol ";
          conda.symbol = "conda ";
          container.symbol = "container ";
          crystal.symbol = "cr ";
          daml.symbol = "daml ";
          dart.symbol = "dart ";
          deno.symbol = "deno ";

          directory = {
            read_only = " ro";
          };

          docker_context.symbol = "docker ";

          dotnet = {
            format = "via [$symbol($version )(target $tfm )]($style)";
            symbol = ".NET ";
          };

          elixir.symbol = "exs ";
          elm.symbol = "elm ";
          erlang.symbol = "erl ";
          fennel.symbol = "fnl ";
          fortran.symbol = "fortran ";

          fossil_branch = {
            symbol = "fossil ";
            truncation_symbol = "...";
          };

          gcloud = {
            symbol = "gcp ";
            disabled = true;
          };

          git_branch = {
            symbol = "git ";
            truncation_symbol = "...";
          };

          gleam.symbol = "gleam ";
          golang.symbol = "go ";
          gradle.symbol = "gradle ";
          guix_shell.symbol = "guix ";
          haskell.symbol = "haskell ";
          haxe.symbol = "hx ";
          helm.symbol = "helm ";

          hg_branch = {
            symbol = "hg ";
            truncation_symbol = "...";
          };

          hostname.ssh_symbol = "ssh ";
          java.symbol = "java ";
          jobs.symbol = "*";
          julia.symbol = "jl ";
          kotlin.symbol = "kt ";
          kubernetes.symbol = "kubernetes ";
          lua.symbol = "lua ";
          nodejs.symbol = "nodejs ";
          memory_usage.symbol = "memory ";

          meson = {
            symbol = "meson ";
            truncation_symbol = "...";
          };

          mojo.symbol = "mojo ";
          nats.symbol = "nats ";
          netns.symbol = "netns ";
          nim.symbol = "nim ";
          nix_shell.symbol = "nix ";
          ocaml.symbol = "ml ";
          odin.symbol = "odin ";
          opa.symbol = "opa ";
          openstack.symbol = "openstack ";

          os.symbols = {
            AIX = "aix ";
            Alpaquita = "alq ";
            AlmaLinux = "alma ";
            Alpine = "alp ";
            ALTLinux = "alt ";
            Amazon = "amz ";
            Android = "andr ";
            AOSC = "aosc ";
            Arch = "rch ";
            Artix = "atx ";
            Bluefin = "blfn ";
            CachyOS = "cach ";
            CentOS = "cent ";
            Debian = "deb ";
            DragonFly = "dfbsd ";
            Elementary = "elem ";
            Emscripten = "emsc ";
            EndeavourOS = "ndev ";
            Fedora = "fed ";
            FreeBSD = "fbsd ";
            Garuda = "garu ";
            Gentoo = "gent ";
            HardenedBSD = "hbsd ";
            Illumos = "lum ";
            Ios = "ios ";
            InstantOS = "inst ";
            Kali = "kali ";
            Linux = "lnx ";
            Mabox = "mbox ";
            Macos = "mac ";
            Manjaro = "mjo ";
            Mariner = "mrn ";
            MidnightBSD = "mid ";
            Mint = "mint ";
            NetBSD = "nbsd ";
            NixOS = "nix ";
            Nobara = "nbra ";
            OpenBSD = "obsd ";
            OpenCloudOS = "ocos ";
            openEuler = "oeul ";
            openSUSE = "osuse ";
            OracleLinux = "orac ";
            PikaOS = "pika ";
            Pop = "pop ";
            Raspbian = "rasp ";
            Redhat = "rhl ";
            RedHatEnterprise = "rhel ";
            RockyLinux = "rky ";
            Redox = "redox ";
            Solus = "sol ";
            SUSE = "suse ";
            Ubuntu = "ubnt ";
            Ultramarine = "ultm ";
            Unknown = "unk ";
            Uos = "uos ";
            Void = "void ";
            Windows = "win ";
            Zorin = "zorn ";
          };

          package.symbol = "pkg ";
          perl.symbol = "pl ";
          php.symbol = "php ";

          pijul_channel = {
            symbol = "pijul ";
            truncation_symbol = "...";
          };

          pixi.symbol = "pixi ";
          pulumi.symbol = "pulumi ";
          purescript.symbol = "purs ";
          python.symbol = "py ";
          quarto.symbol = "quarto ";
          raku.symbol = "raku ";
          red.symbol = "red ";
          rlang.symbol = "r ";
          ruby.symbol = "rb ";
          rust.symbol = "rs ";
          scala.symbol = "scala ";
          shlvl.symbol = "shlvl ";
          spack.symbol = "spack ";
          solidity.symbol = "solidity ";

          status = {
            symbol = "[x](bold red) ";
            not_executable_symbol = "noexec";
            not_found_symbol = "notfound";
            sigint_symbol = "sigint";
            signal_symbol = "sig";
          };

          sudo.symbol = "sudo ";
          swift.symbol = "swift ";
          typst.symbol = "typst ";
          vagrant.symbol = "vagrant ";
          terraform.symbol = "terraform ";
          xmake.symbol = "xmake ";
          zig.symbol = "zig ";
        };
      };

      neovim = {
        enable = true;

        withNodeJs = true;
        withPython3 = true;
        withRuby = false;

        extraConfig = ''
          lua require('config')
        '';
      };

      lf = {
        enable = true;
        previewer.source = pkgs.writeShellScriptBin "lf-preview" ''
          #!/bin/sh

          case "$1" in
            *.tar*) tar tf "$1";;
            *.zip) unzip -l "$1";;
            *.rar) unrar l "$1";;
            *.7z) 7z l "$1";;
            *.pdf) pdftotext "$1" -;;
            *) highlight -O ansi "$1" || cat "$1";;
          esac
        '';
        settings = {
          cursorpreviewfmt = "";
        };
      };
    };
  };
}
