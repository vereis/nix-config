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
  age = {
    secrets = [ ];
    identityPaths = [
      "/Users/${username}/.ssh/id_ed25519"
    ];
  };

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
