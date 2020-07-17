{ config, pkgs, ... }:

{
  imports =
    [
      ../profiles/desktop.nix

      ../modules/nvidia_gpu.nix
      ../modules/plasma5.nix
      ../modules/neovim.nix
      ../modules/nur.nix
      ../modules/zsh.nix
      ../modules/kitty.nix
    ];

  # Personal Modules
  modules.nvidia_gpu.enable = true;
  modules.plasma5.enable = true;
  modules.neovim.enable = true;
  modules.nur.enable = true;
  modules.zsh.enable = true;
  modules.kitty.enable = true;

  # User config + home manager config
  users.users.chris = {
    isNormalUser = true;
    extraGroups = [ "sound" "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager.users.chris = {
    home.packages = with pkgs; [
      pkgs.minecraft
      pkgs.discord
      pkgs.anki
    ];
  };

  # Machine config
  services.xserver = {
    displayManager = {
      defaultSession = "plasma5";
      lightdm.enable = true;
      lightdm.autoLogin.enable = true;
      lightdm.autoLogin.user = "chris";
    };
  };

  networking.hostName = "turtle";
  networking.networkmanager.enable = true;

  system.stateVersion = "20.03";
}

