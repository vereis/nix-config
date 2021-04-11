{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./fzf.nix
    ./ripgrep.nix
  ];

  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.neovim.enable {
    modules.fzf.enable = true;
    modules.ripgrep.enable = true;

    home.file.".dotfiles" = {
      source = builtins.fetchGit {
        url = "https://github.com/vereis/dotfiles";
        ref = "master";
        rev = "c3c5ce6baddb621fb2a4438d18adf24b7ae04f55";
      };
    };

    programs.neovim = {
      enable = true;
          
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython = true;
      withPython3 = true;

      plugins = [ pkgs.fzf pkgs.ripgrep ];

      extraConfig = ''
        let g:config_dir='~/.dotfiles/nvim'
        let g:plugin_dir='~/.nvim_plugins'
        execute "exe 'source' '" . g:config_dir . "/init.vim'"
      '';
    };

    pam.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}

