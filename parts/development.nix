{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      packages.validate-commits = pkgs.writeShellScriptBin "validate-commits" ''
        base_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "master")
        if git rev-parse --verify "origin/$base_branch" >/dev/null 2>&1; then
          git log --format=%H "origin/$base_branch..HEAD" | while read commit; do
            if ! git log --format=%B -n 1 "$commit" | ${pkgs.convco}/bin/convco check --from-stdin 2>&1; then
              echo -e "\033[31mFAIL: Commit $commit has invalid conventional commit message\033[0m" >&2
              exit 1
            fi
          done
        else
          echo -e "\033[33mWARNING: Base branch origin/$base_branch not found, skipping validation\033[0m" >&2
        fi
      '';

      checks.conventional-commits =
        pkgs.runCommand "check-conventional-commits"
          {
            buildInputs = [ config.packages.validate-commits ];
          }
          ''
            cd ${./.}
            validate-commits
            touch $out
          '';

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
          shellcheck.enable = true;
          prettier = {
            enable = true;
            includes = [ "*.json" ];
            excludes = [ "secrets/**" ];
          };
          mdformat = {
            enable = true;
            includes = [ "*.md" ];
            excludes = [ "**/claude-code/**" ];
            settings.wrap = "no";
          };
        };
      };

      pre-commit.settings = {
        hooks = {
          treefmt.enable = true;
          deadnix = {
            enable = true;
            settings = {
              edit = false;
              noUnderscore = false;
            };
          };
          statix = {
            enable = true;
            settings.format = "stderr";
          };
          convco.enable = true;
          validate-branch-commits = {
            enable = true;
            name = "validate branch commits";
            description = "Validate all commits in branch follow Conventional Commits";
            entry = "${config.packages.validate-commits}/bin/validate-commits";
            pass_filenames = false;
            stages = [ "commit-msg" ];
          };
          nix-flake-check = {
            enable = true;
            name = "nix flake check";
            description = "Validate flake (same as CI)";
            entry = "${pkgs.writeShellScript "nix-flake-check" ''
              if [ -n "''${NIX_BUILD_TOP:-}" ]; then
                exit 0
              fi
              ${pkgs.nix}/bin/nix flake check --no-build
            ''}";
            files = "\\.(nix|lock)$";
            pass_filenames = false;
            stages = [ "pre-commit" ];
          };
        };
        excludes = [ "secrets/.*" ];
      };

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
          convco
        ];
        NIX_CONFIG = "experimental-features = nix-command flakes";
        shellHook = ''
          if [ -z "''${NIX_SKIP_HOOKS:-}" ]; then
            ${config.pre-commit.installationScript}
          else
            echo "Skipping git hooks installation (NIX_SKIP_HOOKS is set)"
          fi
        '';
      };
    };
}
