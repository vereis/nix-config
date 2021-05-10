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
      source = ./lorri/service-lorri;
    };

    home.file.".local/bin/lorri-init" = {
      executable = true;
      source = ./lorri/lorri-init;
    };

    programs.zsh.loginExtra = mkIf (config.globals.isWsl && config.modules.zsh.enable) ''
      # == Start modules/docker.nix ==

      # Ensure docker is started automatically upon login
      ${config.globals.localBin}/service-lorri start

      # == End modules/docker.nix ==
    '';
  };
}

