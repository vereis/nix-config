{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        inputs.claudeCode.overlays.default
        (import ../overlays/opencode.nix inputs)
        (import ../overlays/slack.nix inputs)
      ];
    };
  };
}
