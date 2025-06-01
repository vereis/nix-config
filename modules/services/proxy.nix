{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.proxy = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
    firewallPorts = mkOption { type = types.listOf types.port; default = [ 80 443 ]; };
    proxies = mkOption { type = types.attrsOf types.port; default = { }; };
  };

  config = mkIf config.modules.proxy.enable {
    networking.firewall.allowedTCPPorts = mkIf config.modules.proxy.openFirewall config.modules.proxy.firewallPorts;

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "kyubey+proxy@cbailey.co.uk"; # TODO: make this something we pass in

    services.nginx = {
      enable = true;
      virtualHosts =
        builtins.mapAttrs
          (host: port: {
            enableACME = true;
            forceSSL = true;
            locations."/".proxyPass = "http://127.0.0.1:${toString port}/";
          })
          config.modules.proxy.proxies;
    };
  };
}
