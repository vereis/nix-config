{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.git-enhanced = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.git-enhanced.enable {
    home.packages = [
      pkgs.git
      pkgs.gitAndTools.hub

      pkgs.delta
    ];

    # `home-manager` doesn't support the standard `programs.git.*` configuration options
    # within NixOS.
    #
    # This essentially does the same thing :-)
    #
    # Most aliases just create anonymous bash functions to invoke the corresponding `hub` functions.
    # This is because `hub`'s bash and zsh completion is broken, which stops me from being able to simply
    # make a bash/zsh alias: "alias git = hub". Instead, we just allow `hub` functions to be called
    # via the `git` binary :-)
    home.file.".gitconfig" = {
      executable = false;
      text = ''
      [user]    
        email = me@cbailey.co.uk
        name = Chris Bailey

      [color]
        ui = true

      [core]
        pager = delta

      [interactive]
        diffFilter = delta --color-only

      [delta]
        features = side-by-side line-numbers decorations
        whitespace-error-style = 22 reverse

      [delta "decorations"]
        commit-decoration-style = bold yellow box ul
        file-style = bold yellow ul
        file-decoration-style = none

      [alias]
        api = "!f() { hub api $@; \n }; f"
        browse = "!f() { hub browse $@; \n }; f"
        ci-status = "!f() { ci-hub status $@; \n }; f"
        compare = "!f() { hub compare $@; \n }; f"
        create = "!f() { hub create $@; \n }; f"
        delete = "!f() { hub delete $@; \n }; f"
        fork = "!f() { hub fork $@; \n }; f"
        gist = "!f() { hub gist $@; \n }; f"
        issue = "!f() { hub issue $@; \n }; f"
        pr = "!f() { hub pr $@; \n }; f"
        pull-request = "!f() { pull-hub request $@; \n }; f"
        release = "!f() { hub release $@; \n }; f"
        sync = "!f() { hub sync $@; \n }; f"

        push-origin = "!f() { git push origin -u $(git rev-parse --abbrev-ref HEAD) $@; \n }; f"
        rewind = "!f() { git checkout HEAD~$1; \n }; f"
        rewrite = "!f() { git rebase -i HEAD~$1; \n }; f"
      '';
    };
  };
}

