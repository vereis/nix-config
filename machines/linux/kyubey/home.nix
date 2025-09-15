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
      ".config/opencode/opencode.json" = {
        source = ../../../modules/home/tui/opencode/opencode.json;
      };
    };
  };
}
