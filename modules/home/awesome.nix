{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.awesome = {
    enable = mkOption   { type = types.bool; default = false; };
    fontSize = mkOption { type = types.int;  default = 11; };
  };

  config = mkIf config.modules.awesome.enable {
    home.packages = with pkgs; [ awesome rofi maim (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; }) ];

    home.file.".config/awesome" = {
      recursive = true;
      source    = ./awesome;
    };

    home.file.".local/bin/screenshot" = {
      executable = true;
      source     = ./awesome/screenshot;
    };

    programs.rofi = {
      enable = true;
      font = "FantasqueSansMono Nerd Font Mono ${toString config.modules.awesome.fontSize}";
      location = "center";
      theme = {
        "*" = { border = 0; margin = 0; padding = config.modules.awesome.fontSize / 2; spacing = 0; };
      };
    };

    xsession.enable = true;
    xsession.windowManager.awesome.enable = true;

    services.picom = {
      enable = true;
      shadow = false;
      backend = "glx";
      extraArgs = [ "--experimental-backends" ];
      settings = {
        shadow = false;
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'slop'"    # maim (screenshot tool) uses slop to cover the whole screen, don't blur!
          "class_g = 'firefox'" # firefox subwindows shouldn't have blur
        ];
        blur = {
          method = "dual_kawase";
          strength = 8;
        };
      };
    };
  };
}
