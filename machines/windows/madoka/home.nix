{ pkgs, secrets, ... }:

{
  imports = [
    ../../../modules/home/tui.nix
  ];

  modules.tui = {
    enable = true;
    extraPackages = with pkgs; [
      yt-dlp
      tealdeer
      bsd-finger
      claude-code
    ];
    extraFiles = {
      "./.claude/" = {
        recursive = true;
        source = ../../../modules/home/tui/claude;
      };
    };
    extraSessionVariables = {
      GOOGLE_CLOUD_PROJECT = secrets.gemini-cli.googleCloudProject;
      JIRA_API_TOKEN = secrets.vetspire.jiraApiKey;
    };
  };
}
