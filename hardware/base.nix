{ config, lib, pkgs, ... }:

with lib;
{
  config = {
    # Misc.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # SSH Askpass defaults to an X11 session if enabled; this overrides it
    programs.ssh.askPassword = "";

    # TODO: refactor into a profile?
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;
  };
}
