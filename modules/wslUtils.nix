{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.wslUtils = {
    enable = mkOption { type = types.bool; default = false; };
    setDefaultBrowser = mkOption { type = types.bool; default = true; };
    wslHost = mkOption { type = types.str; default = "$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')"; };
  };

  config = mkIf (config.globals.isWsl && config.modules.wslUtils.enable) {
    home.file.".local/bin/edge" = {
      executable = true;
      source = ./wslUtils/edge;
    };

    home.sessionVariables = (mkMerge [
       (mkIf config.modules.wslUtils.setDefaultBrowser {
         BROWSER = "edge";
       })
       {
         WSL_HOST = config.modules.wslUtils.wslHost;
         DISPLAY = "${config.modules.wslUtils.wslHost}:0.0";
         LIBGL_ALWAYS_INDIRECT = "1";
       }
    ]);
  };
}
