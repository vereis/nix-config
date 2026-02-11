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

  nixpkgs.overlays = [
    inputs.nix-openclaw.overlays.default
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
    "d /home/vereis/.config 0700 vereis users - -"
    "d /home/vereis/.config/gh 0700 vereis users - -"
    "d /home/vereis/.local 0700 vereis users - -"
    "d /home/vereis/.local/share 0700 vereis users - -"
    "d /home/vereis/.local/share/opencode 0700 vereis users - -"
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

            if [ -d /home/vereis/.openclaw/agents/main/sessions ]; then
              ${lib.getExe pkgs.python3} <<'PY'
      import glob
      import json
      import os

      for lock_path in glob.glob('/home/vereis/.openclaw/agents/main/sessions/*.jsonl.lock'):
          pid = None
          try:
              with open(lock_path, encoding='utf-8') as f:
                  data = json.load(f)
              pid = int(data.get('pid')) if data.get('pid') is not None else None
          except Exception:
              pass

          alive = False
          if pid and pid > 0:
              try:
                  os.kill(pid, 0)
                  alive = True
              except OSError:
                  alive = False

          if not alive:
              try:
                  os.remove(lock_path)
              except FileNotFoundError:
                  pass
      PY
            fi

            if [ -d /home/vereis/.config/gh ]; then
              ${lib.getExe' pkgs.coreutils "chown"} vereis:users /home/vereis/.config
              ${lib.getExe' pkgs.coreutils "chmod"} u+rwx,go-rwx /home/vereis/.config
              ${lib.getExe' pkgs.coreutils "chown"} -R vereis:users /home/vereis/.config/gh
              ${lib.getExe' pkgs.coreutils "chmod"} -R u+rwX,go-rwx /home/vereis/.config/gh
            fi

            if [ -d /home/vereis/.local/share/opencode ]; then
              ${lib.getExe' pkgs.coreutils "chown"} vereis:users /home/vereis/.local /home/vereis/.local/share
              ${lib.getExe' pkgs.coreutils "chmod"} u+rwx,go-rwx /home/vereis/.local /home/vereis/.local/share
              ${lib.getExe' pkgs.coreutils "chown"} -R vereis:users /home/vereis/.local/share/opencode
              ${lib.getExe' pkgs.coreutils "chmod"} -R u+rwX,go-rwx /home/vereis/.local/share/opencode
            fi
    '';
  };

  nix = {
    optimise.automatic = lib.mkForce false;
    settings.auto-optimise-store = lib.mkForce false;
  };

  microvm = {
    hypervisor = "qemu";
    storeOnDisk = false;

    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        readOnly = true;
      }
    ];

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
      {
        image = "gh-config.img";
        mountPoint = "/home/vereis/.config/gh";
        size = 256;
      }
      {
        image = "opencode-auth.img";
        mountPoint = "/home/vereis/.local/share/opencode";
        size = 512;
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
