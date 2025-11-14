{ pkgs, secrets, ... }:

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
      "./.config/opencode/" = {
        recursive = true;
        source = ../../../modules/home/tui/opencode;
      };
    };
    extraSessionVariables = {
      GOOGLE_CLOUD_PROJECT = secrets.gemini-cli.googleCloudProject;
      JIRA_API_TOKEN = secrets.vetspire.jiraApiKey;
    };
  };
}
