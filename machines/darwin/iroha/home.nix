{ pkgs, config, lib, zjstatus, username, ... }:

{
  imports = [
    ../../../modules/home/git.nix
    ../../../modules/home/kitty.nix
    ../../../modules/home/neovim.nix
    ../../../modules/home/ranger.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/vetspire.nix
    ../../../modules/home/zsh.nix
  ];

  modules.git.enable = true;
  modules.kitty.enable = true;
  modules.kitty.fontSize = 16;
  modules.neovim.enable = true;
  modules.ranger.enable = true;
  modules.tmux.enable = true;
  modules.vetspire.enable = true;
  modules.zsh.enable = true;
}
