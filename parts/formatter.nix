{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          shfmt = {
            enable = true;
            indent_size = 2;
          };
          shellcheck = {
            enable = true;
          };
          prettier = {
            enable = true;
            includes = [ "*.json" ];
            excludes = [ "secrets/**" ];
          };
          mdformat = {
            enable = true;
            includes = [ "*.md" ];
            excludes = [
              "**/claude-code/**"
              "**/opencode/**"
              ".opencode/plans/**"
            ];
            settings = {
              wrap = "no";
            };
          };
        };
      };
    };
}
