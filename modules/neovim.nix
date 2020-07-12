{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.neovim;
  in
  {
    options.modules.neovim = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables my custom neovim configuration
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      home-manager.users.chris.home.file.".dotfiles" = {
        source = builtins.fetchGit {
          url = "https://github.com/vereis/dotfiles";
          ref = "master";
          rev = "b266189325dc93ba469c556be7434e5ed20eba6e";
        };
      };

      home-manager.users.chris.programs.neovim = {
        enable = true;
        
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        withNodeJs = true;
        withPython = true;
        withPython3 = true;

        configure = {
          customRC = ''
            let g:config_dir='~/.dotfiles/nvim'
            let g:plugin_dir='~/.nvim_plugins'
            execute "exe 'source' '" . g:config_dir . "/init.vim'"
          '';
        };
      };
    }]);
  }
