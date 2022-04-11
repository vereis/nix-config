{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.lorri = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.lorri.enable {
    home.packages = mkIf config.globals.isWsl [
      ( 
        pkgs.writeTextFile {
          name = "lorri.wsl-service";
          destination = "/etc/profile.d/lorri.wsl-service";
          text = ''
            ${config.globals.localBin}/service-lorri start
          '';
        }
      )
    ];

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
  };
}

