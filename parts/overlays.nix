{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  flake = {
    overlays = {
      default = lib.composeManyExtensions [
        (import ../overlays/crit.nix inputs)
        (import ../overlays/opencode.nix inputs)
        (import ../overlays/slack.nix inputs)
        (import ../overlays/teams.nix inputs)
      ];
    };
  };
}
