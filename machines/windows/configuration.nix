{ config, lib, pkgs, inputs, system, username, wsl, ... }:

{
  wsl.defaultUser = username;
  wsl.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" "media" ];
    shell = pkgs.zsh;
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [ acpi bsd-finger usbutils ];

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.utf8";

  security.rtkit.enable = true;
  programs.ssh.askPassword = "";

  virtualisation = { docker = { enable = true; enableOnBoot = true; }; };
  system.stateVersion = "24.05";
}
