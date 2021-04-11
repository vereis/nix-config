{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.keychain = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.keychain.enable {
    programs.keychain.enable = true;
    programs.keychain.enableZshIntegration = modules.zsh.enable;
  };
}
