{ pkgs, lib, username, config, ... }:

{
  imports = [ ./services.nix ];

  # Docker Support
  users.users.${username}.extraGroups = [ "docker" ];

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  system.stateVersion = lib.mkForce "24.05";
}
