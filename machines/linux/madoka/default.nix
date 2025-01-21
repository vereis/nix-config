{ pkgs, lib, nixos-wsl, username, config, ... }:

{
  imports = [ ./services.nix ./hardware.nix ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [ discord slack teams-for-linux pavucontrol ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

   # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  services.xserver.dpi = 100;
  services.xserver.windowManager.awesome.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+awesome";
  services.xserver.screenSection = ''
  Option "metamodes" "3840x2160_144 +0+0"
  '';

    fonts.fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "full"; # no difference
        autohint = true; # no difference
      };
      subpixel = {
        # Makes it bolder
        rgba = "rgb";
        lcdfilter = "default"; # no difference
      };
    };

    fonts.fontconfig.allowBitmaps = true;
    fonts.fonts = [
      "${pkgs.fetchFromGitHub {
        owner = "Tecate";
        repo = "bitmap-fonts";
        rev = "5c101c91bf2ed0039aad02f9bf76ddb2018b1f21";
        sha256 = "0s119zln3yrhhscfwkjncj72cr68694643009aam63s2ng4hsmfl";
      }}/bitmap"
      "${pkgs.fetchFromGitHub {
        owner = "sunaku";
        repo = "tamzen-font";
        rev = "3255e8259bc9b880c60ab8b737ec8aa574e00d75";
        sha256 = "6gn8ZHoYqL3XB8nehIcOcD1bPBxSmEdUKNVOfDCXDV4=";
      }}/ttf"
    ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    forceFullCompositionPipeline = true;
  };

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  security.rtkit.enable = true;
  security.polkit.enable = true; # Needed for Sway

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  networking.hostName = "madoka";
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 24800 51413 ];
  networking.firewall.allowedUDPPorts = [ 22 80 443 24800 51413 ];
  system.stateVersion = lib.mkForce "24.05";
}
