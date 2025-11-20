{ inputs, ... }:
{
  flake = {
    overlays = {
      default = import ../overlays/opencode.nix inputs;
    };
  };
}
