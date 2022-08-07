{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.git = {
    enable = mkOption { type = types.bool; default = false; };
  };

  config = mkIf config.modules.git.enable {
    home.packages = with pkgs; [ git gh delta ];

    home.file.".local/bin/git/ssh-migrate.sh" = {
      executable = true;
      source = ./git/migrate-ssh.sh;
    };

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
        # GH Core aliases
        gh          = "!f() { gh $@; \n }; f"
        gist        = "!f() { gh gist $@; \n }; f"
        issue       = "!f() { gh issue $@; \n }; f"
        pr          = "!f() { gh pr $@; \n }; f"
        release     = "!f() { gh release $@; \n }; f"
        repo        = "!f() { gh repo $@; \n }; f"

        alias       = "!f() { gh alias $@; \n }; f"
        api         = "!f() { gh api $@; \n }; f"
        auth        = "!f() { gh auth $@; \n }; f"
        completion  = "!f() { gh completion $@; \n }; f"
        config      = "!f() { gh config $@; \n }; f"
        secret      = "!f() { gh secret $@; \n }; f"
        ssh-key     = "!f() { gh ssh-key $@; \n }; f"

        # Custom aliases
        push-origin = "!f() { git push origin -u $(git rev-parse --abbrev-ref HEAD) $@; \n }; f"
        rewrite     = "!f() { git rebase -i HEAD~$1; \n }; f"
        gloat       = "!f() { git shortlog -sn; \n }; f"
        root        = "!f() { git rev-parse --path-format=absolute --show-toplevel; \n }; f"
        ssh-migrate = "!f() { $HOME/.local/bin/git/ssh-migrate.sh \n }; f"
      '';
    };
  };
}

