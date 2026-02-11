{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        (import ../overlays/bun.nix inputs)
        inputs.opencode.overlays.default
        (import ../overlays/slack.nix inputs)
      ];
    };
  };
}
