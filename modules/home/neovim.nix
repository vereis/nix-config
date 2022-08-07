{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.neovim.enable {
    home.packages = with pkgs; [
      stylua
      sumneko-lua-language-server
      shellcheck
      shfmt
    ];

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = true;

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files | sort -u";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".config/nvim/lua/config.lua".source = ./neovim/config.lua;
    home.file.".local/share/nvim/site/pack/packer/start/packer.nvim" = {
      source = builtins.fetchGit {
        url = "https://github.com/wbthomason/packer.nvim";
        ref = "master";
        rev = "afab89594f4f702dc3368769c95b782dbdaeaf0a";
      };
    };

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;

      extraConfig = ''
      lua require('config')
      '';
    };
  };
}

