{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.fuck = {
    enable = mkOption { type = types.bool; default = false; };

    # instant mode is a little buggy, so I don't want it on by default
    enableInstantMode = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.fuck.enable {
    home = (mkMerge [
       (mkIf config.modules.fuck.enableInstantMode {
         packages = [pkgs.unixtools.script];
       })
       { packages = [pkgs.thefuck];
       }
    ]);

    programs.zsh.initExtra = mkIf config.modules.zsh.enable ''
      # == Start modules/fuck.nix ==
      if [[ ${boolToString config.modules.fuck.enableInstantMode} = true ]]
      then
        eval $(thefuck --alias --enable-experimental-instant-mode)
      else
        eval $(thefuck --alias)
      fi
      # == End modules/fuck.nix ==
    '';
  };
}

