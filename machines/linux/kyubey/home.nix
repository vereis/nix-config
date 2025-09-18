{ pkgs, ... }:

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
      "./.claude/" = { recursive = true; source = ../../../modules/home/tui/claude; };
    };
  };
}
