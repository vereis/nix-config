{ pkgs, lib, config, username, ... }:

with lib;
{
  options.modules.aria2 = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.aria2.enable {
    environment.systemPackages = with pkgs; [ aria ];

    services.aria2 = {
      enable = true;
      extraArguments = "--rpc-listen-all --remote-time=true";
      openPorts = config.modules.aria2.openFirewall;
    };
  };
}
