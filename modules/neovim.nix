{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./fzf.nix
    ./ripgrep.nix
  ];

  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
    setDefaultEditor = mkOption { type = types.bool; default = true; };
  };

  config = mkIf config.modules.neovim.enable {
    modules.fzf.enable = true;
    modules.ripgrep.enable = true;

    home.file.".dotfiles" = {
      source = builtins.fetchGit {
        url = "https://github.com/vereis/dotfiles";
        ref = "master";
        rev = "d410341d4ad740eb43d5e1444a2cf3b9dbff86b7";
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

    programs.zsh.initExtra = mkIf (config.modules.neovim.setDefaultEditor && config.modules.zsh.enable) ''
      # == Start modules/neovim.nix ==

      export VISUAL=nvim
      export EDITOR=nvim

      # == End modules/neovim.nix ==
    '';
  };
}

