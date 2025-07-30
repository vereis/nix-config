{ pkgs, username, wsl, ... }:

{
  wsl.defaultUser = username;
  wsl.enable = true;

  environment.systemPackages = with pkgs; [ xclip ];
}
