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
{
  imports = [
    ./tui/zellij.nix
    ./tui/claude-code
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
          btop
          cacert
          cargo
          delta
          fd
          git-absorb
          ffmpeg
          gcc
          gh
          git
          httpie
          jq
          killall
          lsof
          nerdfetch
          openssh
          openssl
          pciutils
          ripgrep
          rsync
          tree
          unzip
          wget
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
          ".local/bin/git/ssh-migrate.sh" = {
            executable = true;
            source = ./tui/git/migrate-ssh.sh;
          };
          ".local/bin/npiperelay.exe" = {
            executable = true;
            source = ../../bin/npiperelay.exe;
          };
          ".config/nvim/lua/" = {
            recursive = true;
            source = ./tui/neovim/lua;
          };
          ".gitconfig" = {
            executable = false;
            text = builtins.replaceStrings [ "EMAIL_PLACEHOLDER" "USER_PLACEHOLDER" ] [ email user ] (
              builtins.readFile ./tui/git/.gitconfig
            );
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
          ".local/share/atuin/key" = {
            text = secrets.atuin.key;
          };
          ".config/fish/conf.d/starship_transient.fish" = {
            text = ''
              # Enable transient prompt after Starship is loaded
              function __enable_transience_on_prompt --on-event fish_prompt
                if type -q enable_transience
                  enable_transience
                  functions --erase __enable_transience_on_prompt
                end
              end
            '';
          };
        }
        config.modules.tui.extraFiles
      ];

      sessionVariables = {
        FZF_DEFAULT_COMMAND = "rg --files";
        EDITOR = "nvim";
        VISUAL = "nvim";
      }
      // config.modules.tui.extraSessionVariables;
    };

    programs = {
      atuin = {
        enable = true;
        enableFishIntegration = true;
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
      };

      fzf = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
      };

      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd cd" # Use 'cd' instead of 'z'
        ];
      };

      fish = {
        enable = true;

        interactiveShellInit = ''
          # Set vi key bindings
          fish_vi_key_bindings

          # Ctrl-A/E for line navigation
          bind -M insert \ca beginning-of-line
          bind -M insert \ce end-of-line

          # Vi mode: 'v' to edit command in editor
          bind -M default v edit_command_buffer

          # No greeting
          set fish_greeting

          # Always use blinking block cursor (in all vi modes)
          set fish_cursor_default block blink
          set fish_cursor_insert block blink
          set fish_cursor_replace_one block blink
          set fish_cursor_visual block blink
        '';

        shellAliases = {
          vim = "nvim";
        };

        plugins = [ ];

        functions = {
          starship_transient_prompt_func = "starship module character";
        };
      };

      starship = {
        enable = true;
        enableFishIntegration = true;
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
