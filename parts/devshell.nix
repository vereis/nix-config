_: {
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nix-config-devshell";

        packages = with pkgs; [
          deadnix
          statix
          nil
          nixos-rebuild
          home-manager
          git
          jq
          config.treefmt.build.wrapper
        ];

        NIX_CONFIG = "experimental-features = nix-command flakes";
      };
    };
}
