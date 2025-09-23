_: {
  flake = {
    overlays = {
      default = import ../overlays/delta.nix;
    };
  };
}
