{
  pkgs,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ../../../modules/home/tui.nix
  ];

  modules.tui = {
    enable = true;
    extraPackages = with pkgs; [
      yt-dlp
      opencode
    ];
    extraFiles = {
      "./.claude/" = {
        recursive = true;
        source = ../../../modules/home/tui/claude;
      };
    };
    extraSessionVariables = {
      GOOGLE_CLOUD_PROJECT = builtins.readFile osConfig.age.secrets."gemini-project-id.age".path;
      JIRA_API_TOKEN = builtins.readFile osConfig.age.secrets."jira-api-key.age".path;
    };
  };
}
