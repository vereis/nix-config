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

  modules = {
    tui = {
      enable = true;
      extraPackages = with pkgs; [
        yt-dlp
        tealdeer
        bsd-finger
        jira-cli-go
      ];
      extraSessionVariables = {
        GOOGLE_CLOUD_PROJECT = secrets.gemini-cli.googleCloudProject;
        JIRA_API_TOKEN = secrets.vetspire.jiraApiKey;
      };
    };

    gui = {
      enable = true;
      extraPackages = with pkgs; [
        slack
        teams-for-linux
      ];
    };

    agents = {
      enable = true;
      claude-code.enable = true;
    };
  };
}
