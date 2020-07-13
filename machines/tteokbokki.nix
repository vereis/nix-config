{ config, pkgs, ... }:

{
  imports =
    [
      ../profiles/desktop.nix

      ../modules/amd_gpu.nix
      ../modules/intellimouse.nix
      ../modules/dwm.nix
      ../modules/docker.nix
      ../modules/neovim.nix
      ../modules/nur.nix
      ../modules/zsh.nix
      ../modules/lorri.nix
      ../modules/kitty.nix
      ../modules/sway.nix
    ];

  # Personal Modules
  modules.intellimouse.enable = true;
  modules.amd_gpu.enable = true;
  modules.dwm.enable = true;
  modules.docker.enable = true;
  modules.neovim.enable = true;
  modules.nur.enable = true;
  modules.zsh.enable = true;
  modules.lorri.enable = true;
  modules.kitty.enable = true;
  modules.sway.enable = true;

  # User config + home manager config
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "sound" "wheel" "docker" "sway" ];
    shell = pkgs.zsh;
  };

  home-manager.users.chris = {
    home.packages = with pkgs; [
      pkgs.minecraft
      pkgs.discord
    ];
  
    programs = {
      git = {
        enable = true;
        userName = "Chris Bailey";
        userEmail = "me@cbailey.co.uk";
      };
    };
  };

  # Machine config
  services.xserver = {
    displayManager = {
      defaultSession = "none+dwm";
      lightdm.enable = true;
      lightdm.autoLogin.enable = false;
      lightdm.autoLogin.user = "chris";
    };
  };

  networking.hostName = "tteokbokki";
  networking.networkmanager.enable = true;

  networking.useDHCP = false;
  networking.interfaces.enp42s0.useDHCP = false;
  networking.interfaces.wlp39s0.useDHCP = false;

  system.stateVersion = "20.03";
}

