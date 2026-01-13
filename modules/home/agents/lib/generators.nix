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
  }: {
    inherit name description version content supportingFiles;

    # TODO: Implement in Commit 2
    toClaude = throw "mkSkill.toClaude not yet implemented";
    toOpenCode = throw "mkSkill.toOpenCode not yet implemented";
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
  }: {
    inherit name description content;

    # TODO: Implement in Commit 3
    toClaude = throw "mkCommand.toClaude not yet implemented";
    toOpenCode = throw "mkCommand.toOpenCode not yet implemented";
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
