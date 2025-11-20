{
  username,
  pkgs,
  inputs,
  system,
  lib,
  self,
  ...
}:

{
  programs.zsh.enable = lib.mkForce true;
  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    isHidden = false;
  };

  nixpkgs = {
    hostPlatform = system;
    config.allowUnfree = true;
    overlays = [ inputs.self.overlays.default ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings.experimental-features = "nix-command flakes";
    settings.download-buffer-size = 5000000000000000;
  };

  system = {
    keyboard.enableKeyMapping = true;
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 32;
      };

      finder._FXShowPosixPathInTitle = true;
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    configurationRevision = self.rev or self.dirtyRev or null;
  };
}
