{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        (import ../overlays/opencode.nix inputs)
        inputs.claudeCode.overlays.default
        (import ../overlays/slack.nix inputs)
      ];
    };
  };
}
