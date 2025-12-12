{
  pkgs,
  secrets,
  ...
}:
{
  imports = [
    ../../../modules/home/tui.nix
    ../../../modules/home/gui.nix
  ];

  modules.tui = {
    enable = true;
    extraPackages = with pkgs; [
      yt-dlp
      tealdeer
      bsd-finger
      opencode
      jira-cli-go
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

  modules.gui = {
    enable = true;
    extraPackages = with pkgs; [
      slack
      teams-for-linux
    ];
  };
}
