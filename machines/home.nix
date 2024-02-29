{ config, lib, pkgs, username, ... }:

{
  programs.home-manager.enable = true;

  programs.keychain.enable = true;
  programs.keychain.enableZshIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  home = (lib.mkMerge [
    {
      username = "${username}";
      stateVersion = "23.05";
      file.".config/nixpkgs/config.nix" = {
        text = ''
          { allowUnfree = true; }
        '';
      };
      sessionPath = [
        "$HOME/go/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
      ];
    }
    (lib.mkIf pkgs.stdenv.isDarwin { homeDirectory = "/Users/${username}"; })
    (lib.mkIf pkgs.stdenv.isLinux { homeDirectory = "/home/${username}"; })
  ]);
}
