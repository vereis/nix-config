{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.setShell = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.setShell.enable {
    home.file.".local/bin/set-shell" = {
      executable = true;
      text = ''
        #!/bin/sh
        # set-shell    Sets a nix installed shell to start up transparently without chsh
        case $SHELL in
          /bin/ash)
            PROFILE_FILE="$HOME/.profile"
            ;;

          /bin/bash)
            PROFILE_FILE="$HOME/.bash_profile"
            ;;

          /bin/zsh)
            PROFILE_FILE="$HOME/.zprofile"
            ;;

          *)
            echo "Unknown shell: '$SHELL'"
            echo "Please add configuration options for '$SHELL' in '$1'"
            exit 1
            ;;
        esac

        if ! grep -Fq "# added by set-shell" $PROFILE_FILE
        then
          echo "# added by set-shell" >> $PROFILE_FILE
        fi

        if [[ -f "${config.globals.nixProfile}/bin/$1" ]]
        then
          grep -v "added by set-shell" $PROFILE_FILE > temp && mv temp $PROFILE_FILE
          echo "${config.globals.nixProfile}/bin/$1; exit # added by set-shell" >> $PROFILE_FILE
          echo "Shell set to '${config.globals.nixProfile}/bin/$1'"
        else
          echo "'${config.globals.nixProfile}/bin/$1' is not a valid executable, aborting."
          exit 1
        fi
      '';
    };
  };
}
