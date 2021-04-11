{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.lorri = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.lorri.enable {
    programs.direnv.enable = true;
    programs.direnv.enableZshIntegration = config.modules.zsh.enable;

    services.lorri.enable = true;

    home.file.".local/bin/service-lorri" = mkIf config.globals.isWsl {
      executable = true;
      text = ''
        #!/bin/sh
        # service-lorri    Lorri daemon management.
        case "$1" in
          start)
            ${config.globals.nixProfile}/bin/daemonize ${config.globals.nixProfile}/bin/lorri daemon
            ;;

          stop)
            killall lorri &> /dev/null
            ;;

          restart)
            ./$0 stop && ./$0 start
            ;;

          status)
            pidof lorri &> /dev/null && echo "lorri daemon running" || echo "lorri daemon not running"
            ;;

          *)
            echo "Usage:"
            echo "  $1 (start | stop | restart | status)"
            ;;
        esac
      '';
    };

    home.file.".local/bin/lorri-init" = {
      executable = true;
      text = ''
        #!/bin/sh
        # lorri-init    lorri init wrapper setting 'source_up' to true
        lorri init && echo -e "source_up\n$(cat .envrc)" > .envrc
      '';
    };

    programs.zsh.loginExtra = mkIf (config.globals.isWsl && config.modules.zsh.enable) ''
      # == Start modules/docker.nix ==

      # Ensure docker is started automatically upon login
      ${config.globals.localBin}/service-lorri start

      # == End modules/docker.nix ==
    '';
  };
}

