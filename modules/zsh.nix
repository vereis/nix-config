{  config, lib, pkgs, ...}:
with lib;
  let
    cfg = config.modules.zsh;
  in
  {
    options.modules.zsh = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enables zsh configuration with plugins (and fzf)
        '';
      };
    };
  
    config = mkIf cfg.enable (mkMerge [{
      programs.zsh.enable = true;

      programs.zsh.enableCompletion = true;
      programs.zsh.autosuggestions.enable = true;
      programs.zsh.syntaxHighlighting.enable = true;

      # Hoping that home-manager configuration merges with system configuration...
      home-manager.users.chris.home.packages = with pkgs; [
        pkgs.zsh
	pkgs.fzf
      ];

      home-manager.users.chris.programs.zsh.enable = true;
      home-manager.users.chris.programs.zsh.autocd = true;

      home-manager.users.chris.programs.zsh.oh-my-zsh.enable = true;
      home-manager.users.chris.programs.zsh.oh-my-zsh.plugins = [ "git" "sudo" ];
      home-manager.users.chris.programs.zsh.oh-my-zsh.theme = "flazz";

      home-manager.users.chris.programs.fzf.enable = true;
      home-manager.users.chris.programs.fzf.enableZshIntegration = true;
    }]);
  }
