{ inputs, ... }:
{
  flake = {
    overlays = {
      default = inputs.nixpkgs.lib.composeExtensions (import ../overlays/opencode.nix inputs) (
        import ../overlays/slack.nix inputs
      );
    };
  };
}
