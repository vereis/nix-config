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
      ( mkIf config.globals.isWsl ( 
          pkgs.writeTextFile {
            name = "docker.wsl-service";
            destination = "/etc/profile.d/docker.wsl-service";
            text = ''
              ${config.globals.localBin}/service-docker start
            '';
          }
        )
      )
    ];

    home.file.".local/bin/service-docker" = mkIf config.globals.isWsl {
      executable = true;
      source = ./docker/service-docker;
    };

    # TODO: fix this when next using NixOS
    # virtualisation.docker = mkIf config.globals.isNixos {
    #   enable = true;
    #   enableOnBoot = true;
    # };
  };
}
