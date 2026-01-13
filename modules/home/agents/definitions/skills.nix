{ lib, mkSkill }:

let
  stripFrontmatter = (import ../lib/generators.nix { inherit lib; }).stripFrontmatter;

  # Helper to read skill content without frontmatter
  readSkill = path: stripFrontmatter (builtins.readFile path);
in

{
  code-review = mkSkill {
    name = "code-review";
    description = "**MANDATORY**: Apply when reviewing code changes, PR diffs, or code-review requests. Enforces quality standards, warning seriousness, and meaningful comments.";
    content = readSkill ../source/skills/code-review/SKILL.md;
  };

  communication = mkSkill {
    name = "communication";
    description = "Writing and collaboration standards for PR reviews, PR descriptions, and ticket updates. Use when writing messages that other humans will read (PR review comments, PR bodies, JIRA ticket bodies/comments).";
    content = readSkill ../source/skills/communication/SKILL.md;
  };

  git = mkSkill {
    name = "git";
    description = "**MANDATORY**: Load when creating commits or PRs. Covers conventional commits, branching, and PR conventions";
    content = readSkill ../source/skills/git/SKILL.md;
  };

  github-pr = mkSkill {
    name = "github-pr";
    description = "Create, review, and update GitHub pull requests using gh + git with our quality standards. Use when the user mentions PRs, pull requests, GitHub reviews, or asks to open/review a PR.";
    content = readSkill ../source/skills/github-pr/SKILL.md;
  };

  git-workflow = mkSkill {
    name = "git-workflow";
    description = "**MANDATORY**: Enforce branch/worktree workflow. Use when starting work, picking up work, creating branches, using git worktrees, or when asked to implement anything non-trivial. Ensures all work happens on correctly named branches, preferably in dedicated worktrees.";
    content = readSkill ../source/skills/git-workflow/SKILL.md;
  };

  jira = mkSkill {
    name = "jira";
    description = "**MANDATORY**: Load for JIRA operations. Covers ticket structure, JIRA CLI usage, and workflow patterns";
    content = readSkill ../source/skills/jira/SKILL.md;
    supportingFiles = [
      {
        name = "cli-usage.md";
        content = builtins.readFile ../source/skills/jira/cli-usage.md;
      }
      {
        name = "template.md";
        content = builtins.readFile ../source/skills/jira/template.md;
      }
    ];
  };

  planning = mkSkill {
    name = "planning";
    description = "**MANDATORY**: Load when planning complex features or refactorings. Planning process for complex tasks";
    content = readSkill ../source/skills/planning/SKILL.md;
  };

  refactoring = mkSkill {
    name = "refactoring";
    description = "**MANDATORY**: Apply when refactoring or when asked to improve maintainability. Enforces staged, low-risk refactors and clean commit boundaries.";
    content = readSkill ../source/skills/refactoring/SKILL.md;
    supportingFiles = [
      {
        name = "elixir.md";
        content = builtins.readFile ../source/skills/refactoring/elixir.md;
      }
    ];
  };

  standup = mkSkill {
    name = "standup";
    description = "Generate a daily standup update in Markdown using git, GitHub (gh), and Jira (best-effort).";
    content = readSkill ../source/skills/standup/SKILL.md;
  };
}
