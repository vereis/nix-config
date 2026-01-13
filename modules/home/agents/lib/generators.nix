{ lib }:

with lib;

rec {
  # Generate a skill markdown file from structured config
  mkSkill = {
    name,
    description,
    version ? "1.0.0",
    content,
    supportingFiles ? []
  }:
  let
    # Skills have identical frontmatter for both Claude Code and OpenCode
    frontmatter = ''
      ---
      name: ${name}
      description: ${description}
      version: ${version}
      ---
    '';

    markdown = frontmatter + "\n" + content;
  in
  {
    inherit name description version content supportingFiles;

    # Both tools use the same skill format
    toClaude = markdown;
    toOpenCode = markdown;
  };

  # Generate a command markdown file from structured config
  mkCommand = {
    name,
    description,
    content,
    # Tool-agnostic fields
    argumentHint ? null,
    # Claude Code specific
    tools ? [],
    disableModelInvocation ? false,
    # OpenCode specific
    agent ? null,
  }:
  let
    # Claude Code frontmatter (rich)
    claudeFrontmatter =
      let
        lines = [
          "---"
          "description: ${description}"
        ]
        ++ (optionals (argumentHint != null) [ "argument-hint: ${argumentHint}" ])
        ++ (optionals (disableModelInvocation) [ "disable-model-invocation: true" ])
        ++ (optionals (tools != []) [ "allowed-tools: ${concatStringsSep ", " tools}" ])
        ++ [ "---" ];
      in
      concatStringsSep "\n" lines;

    # OpenCode frontmatter (simple with agent)
    openCodeFrontmatter =
      let
        lines = [
          "---"
          "description: ${description}"
        ]
        ++ (optionals (agent != null) [ "agent: ${agent}" ])
        ++ [ "---" ];
      in
      concatStringsSep "\n" lines;
  in
  {
    inherit name description content;

    # Claude Code: Rich frontmatter with tools/permissions
    toClaude = claudeFrontmatter + "\n\n" + content;

    # OpenCode: Simple frontmatter with agent assignment
    toOpenCode = openCodeFrontmatter + "\n\n" + content;
  };

  # Generate an agent markdown file from structured config
  mkAgent = {
    name,
    description,
    content,
    # Tool-agnostic fields
    model ? "sonnet",
    # Claude Code specific
    tools ? [],
    disallowedTools ? [],
    permissionMode ? "plan",
    skills ? [],
    # OpenCode specific (always "subagent" mode)
  }: {
    inherit name description content model;

    # TODO: Implement in Commit 4
    toClaude = throw "mkAgent.toClaude not yet implemented";
    toOpenCode = throw "mkAgent.toOpenCode not yet implemented";
  };
}
