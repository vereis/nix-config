{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        inputs.claudeCode.overlays.default
        (import ../overlays/slack.nix inputs)
      ];
    };
  };
}
