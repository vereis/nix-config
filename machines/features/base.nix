{ config, lib, pkgs, ... }:

with lib;
{
  config = {
    # Misc. preferential stuff...
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      useXkbConfig = true;
      font = "Lat2-Terminus16";
    };

    # SSH Askpass defaults to an X11 session if enabled; this overrides it
    programs.ssh.askPassword = "";

    # I don't see why we should ever _not_ enable these.
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;
  };
}
