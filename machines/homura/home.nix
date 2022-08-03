{ pkgs, ... }:

{
  imports = [
    ../../modules/home/awesome.nix
    ../../modules/home/edge.nix
    ../../modules/home/git.nix
    ../../modules/home/kitty.nix
    ../../modules/home/neovim.nix
    ../../modules/home/vetspire.nix
    ../../modules/home/zsh.nix
  ];

  modules.awesome.enable    = true;
  modules.awesome.fontSize  = 20;
  modules.edge.enable       = true;
  modules.git.enable        = true;
  modules.kitty.enable      = true;
  modules.kitty.fontSize    = 20;
  modules.neovim.enable     = true;
  modules.vetspire.enable   = true;
  modules.zsh.enable        = true;
}
