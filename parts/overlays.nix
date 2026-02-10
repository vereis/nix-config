{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        (import ../overlays/slack.nix inputs)
      ];
    };
  };
}
