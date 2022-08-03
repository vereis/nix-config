{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.neovim.enable {
    home.packages = with pkgs; [ fzf ripgrep shellcheck shfmt ];

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = true;

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files | sort -u";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".dotfiles" = {
      source = builtins.fetchGit {
        url = "https://github.com/vereis/dotfiles";
        ref = "master";
        rev = "8c51f9dbeb0684d01d7949af2ea48140e65625cc";
      };
    };

    programs.neovim = {
      enable = true;
          
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;

      plugins = with pkgs; [ fzf ripgrep ];

      extraConfig = ''
        let g:config_dir='~/.dotfiles/nvim'
        let g:plugin_dir='~/.nvim_plugins'
        execute "exe 'source' '" . g:config_dir . "/init.vim'"
      '';
    };
  };
}

