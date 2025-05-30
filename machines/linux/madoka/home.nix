{ pkgs, ... }:

{
  imports = [
    ../../../modules/home/gui.nix
    ../../../modules/home/git.nix
    ../../../modules/home/neovim.nix
    ../../../modules/home/ranger.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/zsh.nix
  ];

  modules.gui = {
    enable = true;
    extraPackages = with pkgs; [
      discord-canary
      slack
      teams-for-linux
    ];
    customScripts = {
      workspace-vetspire = ../../../bin/workspace-vetspire;
    };
  };

  modules.git.enable = true;
  modules.neovim.enable = true;
  modules.ranger.enable = true;
  modules.tmux.enable = true;
  modules.zsh.enable = true;
}
