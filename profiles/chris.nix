{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./modules/base.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/keychain.nix
    ./modules/kitty.nix
    ./modules/lorri.nix
    ./modules/neovim.nix
    ./modules/ngrok.nix
    ./modules/zsh.nix
    ./modules/slack.nix
    ./modules/teams.nix
    ./modules/synergy.nix
  ]; 

  modules.slack.enable = true;
  modules.teams.enable = true;
  modules.firefox.enable = true;
  modules.git.enable = true;
  modules.keychain.enable = true;
  modules.kitty.enable = true;
  modules.lorri.enable = true;
  modules.neovim.enable = true;
  modules.ngrok.enable = true;
  modules.zsh.enable = true;
  modules.synergy.enable = true;
}
