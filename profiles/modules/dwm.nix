{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.dwm = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.dwm.enable {
    nixpkgs.overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs(_: {
          src = builtins.fetchGit {
            url = "https://github.com/vereis/dwm";
            rev = "1928430adc46e7faea1ebea66ace74f4ce17a31c";
            ref = "personal";
          };
        });
      })
    ];

    home.packages = with pkgs; [ pkgs.dwm ];

    xsession.enable = true;
    xsession.windowManager.command = "${pkgs.dwm}/bin/dwm";

    services.picom.enable = true;
    services.picom.shadow = false;
  };
}
