{
  pkgs,
  secrets,
  nix-openclaw,
  ...
}:
{
  imports = [
    nix-openclaw.homeManagerModules.openclaw
  ];

  programs.openclaw = {
    enable = true;
    package = nix-openclaw.packages.${pkgs.system}.openclaw;
    config = {
      gateway = {
        mode = "local";
        bind = "loopback";
        auth.token = secrets.openclaw.gateway.authToken;
      };

      channels.discord = {
        enabled = true;
        token = secrets.openclaw.discord.botToken;
        blockStreaming = true;
        groupPolicy = "open";
        dm = {
          enabled = true;
          policy = "allowlist";
          allowFrom = [ "382588737441497088" ];
        };
        guilds."1469757243430928521" = {
          requireMention = false;
        };
      };

      plugins.entries.discord.enabled = true;
      commands.native = "auto";
      commands.nativeSkills = "auto";

      agents.defaults = {
        heartbeat = {
          every = "30m";
          target = "last";
          activeHours = {
            start = "07:00";
            end = "02:00";
          };
        };

        userTimezone = "Europe/London";

        model.primary = "opencode/kimi-k2.5";

        subagents.model = {
          primary = "openai/gpt-5.3-codex";
          fallbacks = [
            "opencode/minimax-m2.1"
          ];
        };
      };

      messages = {
        inbound.debounceMs = 1500;
        queue = {
          mode = "collect";
          debounceMs = 1800;
          byChannel.discord = "collect";
        };
      };

      tools.web = {
        fetch.enabled = true;
        search = {
          enabled = true;
          inherit (secrets.openclaw.brave) apiKey;
        };
      };

      env.vars = {
        OPENCODE_API_KEY = secrets.openclaw.opencode.apiKey;
        OPENCODE_ZEN_API_KEY = secrets.openclaw.opencode.apiKey;
      };

    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  home = {
    packages = with pkgs; [
      git
      rsync
      openssh
      ripgrep
      fd
      jq
      opencode
      which
      yq-go
      sqlite
      diffutils
      patch
      zip
      unzip
      gnutar
      gzip
      xz
      bzip2
      coreutils
      util-linux
      vim
      dnsutils
      iputils
      traceroute
      mtr
      nmap
      whois
      bat
      eza
      fzf
      zoxide
      delta
      btop
      websocat
      csvkit
      xmlstarlet
      pandoc
      ffmpeg
      imagemagick
      sox
    ];

    sessionVariables.OPENCODE_API_KEY = secrets.openclaw.opencode.apiKey;

    file = {
      ".openclaw/openclaw.json".force = true;
      ".cc-safety-net/config.json".source = ../../../modules/home/tui/opencode/safety-net-config.json;
      ".config/opencode/" = {
        recursive = true;
        source = ../../../modules/home/tui/opencode;
      };
    };
  };

  systemd.user.services.openclaw-gateway = {
    Service.Environment = [
      "PATH=/etc/profiles/per-user/vereis/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
    ];
    Install.WantedBy = [ "default.target" ];
  };
}
