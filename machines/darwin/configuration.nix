{
  self,
  config,
  username,
  ...
}:

{
  services.nix-daemon.enable = true;

  config.users.${username} = {
    home = "/Users/${username}";
    isHidden = false;
  };

  system = {
    keyboard.enableKeyMapping = true;

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
    stateVersion = 4;
  };
}
