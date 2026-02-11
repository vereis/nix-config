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
        groupPolicy = "allowlist";
        dm = {
          enabled = true;
          policy = "pairing";
        };
        guilds."1469757243430928521".requireMention = false;
      };

      plugins.entries.discord.enabled = true;
      commands.native = "auto";
      commands.nativeSkills = "auto";

      agents.defaults = {
        model = {
          primary = "anthropic/claude-opus-4-6";
          fallbacks = [
            "openai-codex/gpt-5.3-codex"
            "opencode/kimi-k2.5"
          ];
        };

        subagents = {
          model = {
            primary = "openai-codex/gpt-5.3-codex";
            fallbacks = [
              "anthropic/claude-opus-4-6"
              "opencode/kimi-k2.5"
            ];
          };
        };
      };
    };
  };

  home.sessionVariables.OPENCODE_API_KEY = secrets.openclaw.opencode.apiKey;

  home.file.".openclaw/openclaw.json".force = true;

  systemd.user.services.openclaw-gateway = {
    Install.WantedBy = [ "default.target" ];
  };
}
