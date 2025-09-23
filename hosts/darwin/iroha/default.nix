{
  self,
  config,
  lib,
  pkgs,
  system,
  inputs,
  zjstatus,
  username,
  homebrew,
  home-manager,
  ...
}:

{
  homebrew = {
    enable = true;
    casks = [
      "tailscale"
      "kitty"
      "wezterm"
      "firefox"
      "microsoft-teams"
      "slack"
      "docker"
    ];
  };
}
