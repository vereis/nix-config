{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.zsh = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.zsh.enable {
    home.packages = [
      pkgs.zsh
    ];

    programs.zsh.enable = true;

    programs.zsh.enableCompletion = true;
    programs.zsh.enableAutosuggestions = true;

    programs.zsh.autocd = true;

    programs.zsh.oh-my-zsh.enable = true;
    programs.zsh.oh-my-zsh.plugins = [ "git" "sudo" ];
    programs.zsh.oh-my-zsh.theme = "clean";

    # home-manager's zsh doesn't support the syntax highlighting plugin, so fetch it ourselves...
    programs.zsh.plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
    ];

    programs.zsh.initExtraFirst = ''
      # == Start modules/zsh.nix ==

      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then . "$HOME/.nix-profile/etc/profile.d/nix.sh"; fi

      # == End modules/zsh.nix ==
    '';

    programs.zsh.initExtra = ''
      # == Start modules/zsh.nix ==

      # Execute any custom wsl-service scripts
      for file in /etc/profile.d/**/*.wsl-service(DN); . $file
      for file in $HOME/.nix-profile/etc/profile.d/**/*.wsl-service(DN); . $file

      # == End modules/zsh.nix ==
    '';
  };
}
