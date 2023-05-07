{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.ncmpcpp = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.ncmpcpp.enable {
    programs.ncmpcpp = {
      enable = true;
      package = pkgs.ncmpcpp.override { visualizerSupport = true; clockSupport = true; };

      bindings = [
        { key = "j"; command = "scroll_down"; }
        { key = "k"; command = "scroll_up"; }
        { key = "J"; command = [ "select_item" "scroll_down" ]; }
        { key = "K"; command = [ "select_item" "scroll_up" ]; }
      ];
    };
  };
}
