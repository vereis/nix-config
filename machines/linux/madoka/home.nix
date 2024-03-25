{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/awesome.nix
    ../../../modules/home/firefox.nix
    ../../../modules/home/git.nix
    ../../../modules/home/kitty.nix
    ../../../modules/home/ncmpcpp.nix
    ../../../modules/home/neovim.nix
    ../../../modules/home/ranger.nix
    ../../../modules/home/vetspire.nix
    ../../../modules/home/jira.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/vetspire.nix
    ../../../modules/home/zsh.nix
  ];

  modules.awesome.enable = true;
  modules.awesome.fontSize = 13;
  modules.firefox.enable = true;
  modules.git.enable = true;
  modules.kitty.enable = true;
  modules.kitty.fontSize = 13;
  modules.ncmpcpp.enable = true;
  modules.neovim.enable = true;
  modules.ranger.enable = true;
  modules.tmux.enable = true;
  modules.vetspire.enable = true;
  modules.jira.enable = true;
  modules.zsh.enable = true;
}
