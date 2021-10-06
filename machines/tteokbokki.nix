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
    ../modules/setShell.nix
    ../modules/git-enhanced.nix
  ];

  modules.base.enable = true;
  modules.zsh.enable = true;
  modules.docker.enable = true;
  modules.neovim.enable = true;
  modules.lorri.enable = true;
  modules.keychain.enable = true;
  modules.setShell.enable = true;
  modules.git-enhanced.enable = true;
  modules.ngrok.enable = true;
}
