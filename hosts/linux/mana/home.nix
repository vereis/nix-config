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

        model = {
          primary = "opencode/kimi-k2.5";
          fallbacks = [
            "opencode/kimi-k2.5-free"
          ];
        };

        subagents = {
          model = {
            primary = "opencode/kimi-k2.5";
            fallbacks = [
              "opencode/kimi-k2.5-free"
            ];
          };
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

      models.providers.opencode = {
        baseUrl = "https://opencode.ai/zen/v1";
        inherit (secrets.openclaw.opencode) apiKey;
        api = "openai-completions";
        models = [
          {
            id = "kimi-k2.5";
            name = "Kimi K2.5";
            contextWindow = 262144;
            maxTokens = 8192;
          }
          {
            id = "kimi-k2.5-free";
            name = "Kimi K2.5 Free";
            contextWindow = 262144;
            maxTokens = 8192;
          }
        ];
      };
    };
  };

  home.sessionVariables.OPENCODE_API_KEY = secrets.openclaw.opencode.apiKey;

  home.file.".openclaw/openclaw.json".force = true;

  systemd.user.services.openclaw-gateway = {
    Install.WantedBy = [ "default.target" ];
  };
}
