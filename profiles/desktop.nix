{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];
  
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  home-manager.users.chris.home.packages = with pkgs; [
    pkgs.compton
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

  home-manager.users.chris.services.picom.enable = true;
  home-manager.users.chris.services.picom.backend = "xr_glx_hybrid";
  home-manager.users.chris.services.picom.vSync = true;
  home-manager.users.chris.services.picom.inactiveDim = "0.133";
}
