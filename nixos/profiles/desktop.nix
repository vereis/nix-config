{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];
  
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  home-manager.users.chris.home.packages = with pkgs; [
    pkgs.ctags
    pkgs.neofetch

    # Work
    pkgs.irssi
    pkgs.slack
    pkgs.firefox
  ];

  home-manager.users.chris.programs.home-manager.enable = true;
  home-manager.users.chris.programs.irssi.enable = true;
  home-manager.users.chris.programs.firefox.enable = true;
}
