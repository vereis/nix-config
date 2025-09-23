{
  pkgs,
  lib,
  config,
  nix-minecraft,
  ...
}:

with lib;
{
  options.modules.minecraft = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };

    servers = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            autoStart = mkOption {
              type = types.bool;
              default = true;
            };

            package = mkOption {
              type = types.package;
              default = pkgs.minecraft-server;
              description = "Minecraft server package (vanilla, fabric, paper, etc.)";
            };

            jvmOpts = mkOption {
              type = types.either types.str (types.listOf types.str);
              default = "-Xms6144M -Xmx8192M";
              description = "JVM options for the server";
            };

            serverProperties = mkOption {
              type = types.attrsOf types.anything;
              default = { };
              description = "server.properties configuration";
            };

            whitelist = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Whitelisted players by UUID";
            };

            operators = mkOption {
              type = types.attrsOf (
                types.submodule {
                  options = {
                    name = mkOption { type = types.str; };
                    level = mkOption {
                      type = types.int;
                      default = 4;
                    };
                    bypassesPlayerLimit = mkOption {
                      type = types.bool;
                      default = false;
                    };
                  };
                }
              );
              default = { };
              description = "Server operators";
            };

            restart = mkOption {
              type = types.str;
              default = "always";
              description = "Systemd restart behavior";
            };

            stopCommand = mkOption {
              type = types.str;
              default = "stop";
              description = "Console command to stop server";
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf config.modules.minecraft.enable {
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = config.modules.minecraft.openFirewall;

      servers = mapAttrs (name: serverConfig: {
        enable = serverConfig.enable;
        autoStart = serverConfig.autoStart;
        openFirewall = config.modules.minecraft.openFirewall;
        package = serverConfig.package;
        jvmOpts = serverConfig.jvmOpts;
        restart = serverConfig.restart;
        stopCommand = serverConfig.stopCommand;
        serverProperties = serverConfig.serverProperties;
        whitelist = serverConfig.whitelist;
        operators = serverConfig.operators;
      }) config.modules.minecraft.servers;
    };
  };
}
