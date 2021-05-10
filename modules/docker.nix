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
      source = ./docker/service-docker;
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
