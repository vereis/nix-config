{
  pkgs,
  lib,
  config,
  username,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    mkMerge
    types
    listToAttrs
    ;
in
{
  options.modules.docker = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    rootless = mkOption {
      type = types.bool;
      default = false;
      description = "Enable rootless Docker mode";
    };
    autoPrune = mkOption {
      type = types.bool;
      default = true;
      description = "Enable weekly auto-pruning of unused images";
    };
    extraUsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional users to add to docker group (current user always included)";
    };
  };

  config = mkIf config.modules.docker.enable {
    virtualisation.docker = mkMerge [
      { enable = true; }
      (mkIf config.modules.docker.rootless {
        rootless.enable = true;
        rootless.setSocketVariable = true;
      })
      (mkIf config.modules.docker.autoPrune {
        autoPrune.enable = true;
        autoPrune.dates = "weekly";
      })
    ];

    users.users = listToAttrs (
      map (user: {
        name = user;
        value = {
          extraGroups = [ "docker" ];
        };
      }) ([ username ] ++ config.modules.docker.extraUsers)
    );
  };
}
