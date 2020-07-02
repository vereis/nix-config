{ config, pkgs, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "cbailey.co.uk";

  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  environment.systemPackages = with pkgs; [
    git 
    wget
    vim
    direnv
  ];

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  users.users.root.shell = pkgs.zsh;

  services.lorri.enable = true;
}
