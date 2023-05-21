{ pkgs, lib, config, username, ... }:

with lib;
{
  options.modules.tailscale = {
    enable = mkOption { type = types.bool; default = false; };
    openFirewall = mkOption { type = types.bool; default = false; };
    authTokenFile = mkOption { type = types.path; default = ../../secrets/tailscale; };
  };

  config = mkIf config.modules.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale jq ];

    services.tailscale.enable = true;

    # Punch hole in firewall to allow access via tailnet
    networking.firewall = mkIf config.modules.tailscale.openFirewall {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 ];
    };

    # Automatically connect/auth w/ Tailscale
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      # tailscale auth key is read from `$HOME/.tailscale.ak`
      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey ${(builtins.readFile config.modules.tailscale.authTokenFile)}
      '';
    };
  };
}
