{ pkgs, username, wsl, ... }:

{
  wsl.defaultUser = username;
  wsl.enable = true;

  environment.systemPackages = with pkgs; [ xclip ];
  environment.variables.BROWSER = "/mnt/c/Program\\ Files\\ \\(x86\\)/Microsoft/Edge/Application/msedge.exe";
}
