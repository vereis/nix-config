{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/gui.nix
    ../../../modules/home/tui.nix
  ];

  modules.gui = {
    enable = true;
    extraPackages = with pkgs; [
      discord-canary
      slack
      teams-for-linux
      steam
    ];
    customScripts = {
      workspace-vetspire = ../../../bin/workspace-vetspire;
    };
  };

  modules.tui = {
    enable = true;
    extraPackages = with pkgs; [
      yt-dlp
      tealdeer
      bsd-finger
      claude-code
      gemini-cli
    ];
  };
}
