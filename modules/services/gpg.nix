{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.gpg = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.gpg.enable {
    environment.systemPackages = [ pkgs.pinentry-curses ];
    services.pcscd.enable = true;
    programs.gnupg.agent = {
       enable = true;
       pinentryFlavor = "curses";
       enableSSHSupport = true;
    };
  };
}
