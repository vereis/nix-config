{ pkgs, username, wsl, ... }:

{
  wsl.defaultUser = username;
  wsl.enable = true;
}
