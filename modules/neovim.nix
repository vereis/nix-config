{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./fzf.nix
    ./ripgrep.nix
    ./shellcheck.nix
    ./shellformat.nix
  ];

  options.modules.neovim = {
    enable = mkOption { type = types.bool; default = false; };
    setDefaultEditor = mkOption { type = types.bool; default = true; };
    enableCocDeps = mkOption { type = types.bool; default = true; };
  };

  config = mkIf config.modules.neovim.enable {
    # Non-optional deps
    modules.fzf.enable = true;
    modules.ripgrep.enable = true;

    # Used by coc-diagnostics
    modules.shellcheck.enable = mkIf (config.modules.neovim.enableCocDeps) true;
    modules.shellformat.enable = mkIf (config.modules.neovim.enableCocDeps) true;

    home.file.".dotfiles" = {
      source = builtins.fetchGit {
        url = "https://github.com/vereis/dotfiles";
        ref = "master";
        rev = "b30d56f5c97b2189436a797c36c095bf33505dea";
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

    home.sessionVariables = mkIf (config.modules.neovim.setDefaultEditor) {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}

