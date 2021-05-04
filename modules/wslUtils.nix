{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.wslUtils = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf (config.globals.isWsl && config.modules.wslUtils.enable) {
    home.file.".local/bin/edge" = {
      executable = true;
      text = ''
        #!/bin/sh
        # edge    Wrapper for launching Microsoft Edge
        (cmd.exe /c start microsoft-edge:"$@") > /dev/null 2>&1
      '';
    };

    programs.zsh.initExtra = mkIf config.modules.zsh.enable ''
      # == Start modules/wslUtils.nix ==
      export BROWSER="edge"
      # == End modules/wslUtils.nix ==
    '';
  };
}
