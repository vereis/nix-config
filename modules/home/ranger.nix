{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.ranger = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.ranger.enable {
    home.packages = with pkgs; [ ranger bat ffmpeg bat unrar unzip ];
  };
}
