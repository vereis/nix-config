{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.gpg = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.gpg.enable {
    environment.systemPackages = with pkgs; [
      pinentry-curses
    ];

    programs.ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };
}
