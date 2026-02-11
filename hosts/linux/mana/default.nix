{
  inputs,
  lib,
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

  users.users.vereis.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMG37Ow3/XMK/R4TLn6eJkuv6GlVUPoKHb7niULgtKxV"
  ];

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
