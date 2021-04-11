{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.docker = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.docker.enable {
    home.packages = [
      pkgs.docker
      pkgs.docker-compose
      ( mkIf config.globals.isWsl pkgs.daemonize )
    ];

    home.file.".local/bin/service-docker" = mkIf config.globals.isWsl {
      executable = true;
      text = ''
        #!/bin/sh
        # service-docker    Docker daemon management for WSL distros. Uses `wsl.exe` for privelege escalation.
        case "$1" in
          start)
            wsl.exe -u root -d ${config.globals.wslDistro} -e ${config.globals.nixProfile}/bin/daemonize ${config.globals.nixProfile}/bin/dockerd
            ;;

          stop)
            wsl.exe -u root -d ${config.globals.wslDistro} -e killall dockerd &> /dev/null
            ;;

          restart)
            ./$0 stop && ./$0 start
            ;;

          status)
            pidof dockerd &> /dev/null && echo "docker daemon running" || echo "docker daemon not running"
            ;;

          *)
            echo "Usage:"
            echo "  $1 (start | stop | restart | status)"
            ;;
        esac
      '';
    };

    programs.zsh.loginExtra = mkIf (config.globals.isWsl && config.modules.zsh.enable) ''
      # == Start modules/docker.nix ==

      # Ensure docker is started automatically upon login
      ${config.globals.localBin}/service-docker start

      # == End modules/docker.nix ==
    '';

    # TODO: fix this when next using NixOS
    # virtualisation.docker = mkIf config.globals.isNixos {
    #   enable = true;
    #   enableOnBoot = true;
    # };
  };
}
