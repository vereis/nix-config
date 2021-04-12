{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.wslUtils = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf (config.globals.isWsl && config.modules.wslUtils.enable) {
    home.file.".local/bin/open" = {
      executable = true;
      text = ''
        #!/bin/sh
        # open    Start applications in Windows
        powershell.exe Start $1
      '';
    };
  };
}
