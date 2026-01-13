{ lib, mkAgent }:

let
  stripFrontmatter = (import ../lib/generators.nix { inherit lib; }).stripFrontmatter;

  # Helper to read agent content without frontmatter
  readAgent = path: stripFrontmatter (builtins.readFile path);
in

{
  code-reviewer = mkAgent {
    name = "code-reviewer";
    description = "Expert code review specialist. Proactively reviews recent code changes for correctness, security, maintainability, and test quality. Returns concise, actionable feedback to the primary agent.";
    model = "opus";
    tools = [ "Read" "Grep" "Glob" ];
    disallowedTools = [ "Edit" "Write" ];
    permissionMode = "plan";
    skills = [ "code-review" ];
    content = readAgent ../source/agents/code-reviewer.md;
  };

  refactorer = mkAgent {
    name = "refactorer";
    description = "Refactoring specialist. Reduces complexity and improves clarity without changing behavior unless explicitly requested. Returns staged refactor steps the primary agent can implement as clean, atomic commits.";
    model = "opus";
    tools = [ "Read" "Grep" "Glob" ];
    disallowedTools = [ "Edit" "Write" ];
    permissionMode = "plan";
    skills = [ "refactoring" ];
    content = readAgent ../source/agents/refactorer.md;
  };
}
