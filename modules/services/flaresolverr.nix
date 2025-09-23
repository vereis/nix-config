{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
{
  options.modules.flareSolverr = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.flareSolverr.enable {
    networking.firewall.allowedTCPPorts = mkIf config.modules.flareSolverr.openFirewall [ 8191 ];

    virtualisation.oci-containers.containers."flareSolverr" = {
      autoStart = true;
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        "TZ" = "Europe/London";
        "LOG_LEVEL" = "info";
        "LOG_HTML" = "false";
        "CAPTCHA_SOLVER" = "none";
      };
      ports = [ "8191:8191" ];
    };
  };
}
