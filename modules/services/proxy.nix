{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.proxy = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
    firewallPorts = mkOption { type = types.listOf types.port; default = [ 80 443 ]; };
    proxies = mkOption {
      description = "Template for defining reverse proxy hosts.";
      type = types.attrsOf (
        types.submodule {
          options = {
            port = mkOption { type = types.port; };
            http2 = mkOption { type = types.bool; default = true; };
            useSSL = mkOption { type = types.bool; default = false; };
            extraConfig = mkOption { type = types.str; default = ""; };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf config.modules.proxy.enable {
    networking.firewall.allowedTCPPorts = mkIf config.modules.proxy.openFirewall config.modules.proxy.firewallPorts;

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "kyubey+proxy@cbailey.co.uk"; # TODO: make this something we pass in

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts =
        builtins.mapAttrs
          (host: config: {
            enableACME = config.useSSL;
            forceSSL = config.useSSL;
            locations."/".proxyPass = "http://127.0.0.1:${toString config.port}/";
            locations."/".proxyWebsockets = true;
            http2 = config.http2;
            extraConfig = config.extraConfig;
          })
          config.modules.proxy.proxies;
    };
  };
}
