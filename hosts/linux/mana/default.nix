{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.microvm.nixosModules.microvm
  ];

  networking.hostName = "mana";

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.vereis = {
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMG37Ow3/XMK/R4TLn6eJkuv6GlVUPoKHb7niULgtKxV"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/vereis/.openclaw 0700 vereis users - -"
    "d /home/vereis/.openclaw/workspace 0700 vereis users - -"
    "d /home/vereis/.openclaw/workspace/memory 0700 vereis users - -"
  ];

  systemd.services.openclaw-state-permissions = {
    description = "Ensure OpenClaw state is writable by vereis";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ -d /home/vereis/.openclaw ]; then
        ${lib.getExe' pkgs.coreutils "chown"} -R vereis:users /home/vereis/.openclaw
        ${lib.getExe' pkgs.coreutils "chmod"} -R u+rwX,go-rwx /home/vereis/.openclaw
      fi
    '';
  };

  nix = {
    optimise.automatic = lib.mkForce false;
    settings.auto-optimise-store = lib.mkForce false;
  };

  microvm = {
    hypervisor = "qemu";

    writableStoreOverlay = "/nix/.rw-store";
    volumes = [
      {
        image = "rw-store.img";
        mountPoint = "/nix/.rw-store";
        size = 2048;
      }
      {
        image = "openclaw-state.img";
        mountPoint = "/home/vereis/.openclaw";
        size = 4096;
      }
    ];

    vcpu = 2;
    mem = 3072;

    interfaces = [
      {
        type = "user";
        id = "vm-mana";
        mac = "02:00:00:00:83:01";
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };
}
