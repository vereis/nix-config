{ config, pkgs, ... }:

{
  imports = [
    ../profiles/wsl.nix
    ../modules/base.nix
    ../modules/docker.nix
    ../modules/zsh.nix
    ../modules/ngrok.nix
    ../modules/neovim.nix
    ../modules/keychain.nix
    ../modules/lorri.nix
    ../modules/set-shell.nix
    ../modules/git.nix
    ../modules/kitty.nix
    ../modules/dwm.nix
  ]; 

  modules.base.enable = true;
  modules.zsh.enable = true;
  modules.docker.enable = true;
  modules.neovim.enable = true;
  modules.lorri.enable = true;
  modules.keychain.enable = true;
  modules.git.enable = true;
  modules.ngrok.enable = true;
  modules.kitty.enable = true;
  modules.dwm.enable = true;
}
