{ config, lib, pkgs, inputs, username, ... }:

{
  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
      acpi
      cacert
      fd
      gcc
      git
      htop
      httpie
      killall
      lsof
      openssh
      openssl
      pciutils
      pfetch
      ripgrep
      tmux
      tree
      unzip
      usbutils
      wget
      xclip
    ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.utf8";

  nix = {
    package = pkgs.nixFlakes;
    settings.auto-optimise-store = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    getty.autologinUser = "${username}";

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    # Allow Home-Manager to control starting WMs via XSession
    xserver = {
      enable = true;
      layout = "us";
      xkbVariant = "";
      libinput.enable = true;

      displayManager = {
        defaultSession = "xsession";
        autoLogin.user = "${username}";

        session = [{
          manage = "desktop";
          name = "xsession";
          start = ''
	          exec $HOME/.xsession &
	          waitPID=$!
	        '';
        }];
      };
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  programs.ssh.askPassword = "";

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  system.stateVersion = "22.11";
}
