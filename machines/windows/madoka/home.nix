{ pkgs, ... }:

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
      "./.claude/" = { recursive = true; source = ../../../modules/home/tui/claude; };
    };
  };
}
