{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.neovim.enable {
    home.packages = with pkgs; [ shellcheck shfmt cargo go rebar3 ];

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = true;

    home.sessionVariables = {
      FZF_DEFAULT_COMMAND = "rg --files | sort -u";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".config/nvim/lua/" = {
      source = ./neovim/lua;
      recursive = true;
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
