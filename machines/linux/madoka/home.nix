{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/git.nix
    ../../../modules/home/ncmpcpp.nix
    ../../../modules/home/neovim.nix
    ../../../modules/home/ranger.nix
    ../../../modules/home/jira.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/zsh.nix
  ];

  modules.git.enable = true;
  modules.ncmpcpp.enable = true;
  modules.neovim.enable = true;
  modules.ranger.enable = true;
  modules.tmux.enable = true;
  modules.jira.enable = true;
  modules.zsh.enable = true;
}
