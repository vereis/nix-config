{ lib, mkCommand }:

let
  stripFrontmatter = (import ../lib/generators.nix { inherit lib; }).stripFrontmatter;

  # Helper to read command content without frontmatter
  readCommand = path: stripFrontmatter (builtins.readFile path);
in

{
  "code:refactor" = mkCommand {
    name = "code:refactor";
    description = "Refactor-analysis wrapper (prefer skill auto-trigger)";
    argumentHint = "[scope]";
    disableModelInvocation = true;
    tools = [ "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git symbolic-ref:*)" "Bash(git branch:*)" "Read" "Grep" "Glob" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/code:refactor.md");
  };

  "code:review" = mkCommand {
    name = "code:review";
    description = "Code review wrapper (prefer skill auto-trigger)";
    argumentHint = "[scope]";
    disableModelInvocation = true;
    tools = [ "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git symbolic-ref:*)" "Bash(git branch:*)" "Read" "Grep" "Glob" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/code:review.md");
  };

  "jira:create" = mkCommand {
    name = "jira:create";
    description = "Create a JIRA ticket (wrapper around skills)";
    argumentHint = "[ticket-summary]";
    disableModelInvocation = true;
    tools = [ "Bash(jira:*)" "Bash(mkdir:*)" "Bash(mv:*)" "Bash(cat:*)" "Bash(grep:*)" "Bash(head:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/jira:create.md");
  };

  "jira:review" = mkCommand {
    name = "jira:review";
    description = "Review/update a JIRA ticket (wrapper around skills)";
    argumentHint = "[ticket-key-or-url]";
    disableModelInvocation = true;
    tools = [ "Bash(jira:*)" "Bash(grep:*)" "Bash(mkdir:*)" "Bash(cat:*)" "Bash(mv:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/jira:review.md");
  };

  "pr:create" = mkCommand {
    name = "pr:create";
    description = "Create a pull request (wrapper around skills)";
    argumentHint = "[base-branch]";
    disableModelInvocation = true;
    tools = [ "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git branch:*)" "Bash(git symbolic-ref:*)" "Bash(git push:*)" "Bash(gh pr create:*)" "Bash(gh repo view:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/pr:create.md");
  };

  "pr:review" = mkCommand {
    name = "pr:review";
    description = "Review a PR (wrapper around skills)";
    argumentHint = "[pr-number-or-url]";
    disableModelInvocation = true;
    tools = [ "Bash(gh pr view:*)" "Bash(gh pr diff:*)" "Bash(gh pr checks:*)" "Bash(gh pr status:*)" "Bash(gh repo view:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/pr:review.md");
  };

  "standup:daily" = mkCommand {
    name = "standup:daily";
    description = "Generate a daily standup update in Markdown (git + gh + jira)";
    argumentHint = "[since]";
    disableModelInvocation = true;
    tools = [ "Bash(date:*)" "Bash(git status:*)" "Bash(git log:*)" "Bash(gh api:*)" "Bash(gh pr status:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/standup:daily.md");
  };

  "worktree:new" = mkCommand {
    name = "worktree:new";
    description = "Create a new git worktree for a task (enforces branch naming)";
    argumentHint = "<dir> <branch>";
    disableModelInvocation = false;  # Note: original doesn't have this flag
    tools = [ "Bash(git rev-parse:*)" "Bash(git show-ref:*)" "Bash(git worktree:*)" "Bash(realpath:*)" "Bash(mkdir:*)" "Bash(test:*)" "Bash(pwd:*)" ];
    agent = "build";  # For OpenCode
    content = readCommand (../source/commands + "/worktree:new.md");
  };
}
