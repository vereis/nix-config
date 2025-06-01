{ pkgs, lib, config, nix-minecraft, ... }:

with lib;
{
  options.modules.minecraft = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.minecraft.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = config.modules.minecraft.openFirewall;
      servers.uwuverse = {
        enable = true;
        autoStart = true;
        openFirewall = config.modules.minecraft.openFirewall;
        jvmOpts = "-Xms6144M -Xmx8192M";
        serverProperties = {
          difficulty = 3;
          gamemode = 1;
          max-players = 10;
          view-distance = 32;
          enable-command-block = true;
          motd = "Ahoy!! Welcome to `Uwuverse Minecraft`!!";
          enable-rcon = true;
          "rcon.password" = "uwu";
        };
      };
    };
  };
}
