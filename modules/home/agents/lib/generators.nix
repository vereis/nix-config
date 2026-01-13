{ lib }:

with lib;

rec {
  # Helper: Strip YAML frontmatter from markdown content
  # Removes everything between --- ... --- at the start of the file
  stripFrontmatter = content:
    let
      lines = splitString "\n" content;
      # Check if first line is ---
      startsWithFrontmatter = head lines == "---";
      # Find the closing --- (skip first line)
      findClosing = lines:
        let
          indexed = lib.imap0 (i: line: { inherit i line; }) lines;
          closing = lib.findFirst (x: x.line == "---" && x.i > 0) null indexed;
        in
        if closing == null then 0 else closing.i;
      closingIndex = if startsWithFrontmatter then findClosing lines else 0;
      # Drop lines up to and including the closing ---
      contentLines = if closingIndex > 0 then drop (closingIndex + 1) lines else lines;
    in
    concatStringsSep "\n" contentLines;

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
  }:
  let
    # Helper to format list as YAML
    yamlList = items:
      if items == [] then ""
      else "\n" + concatMapStringsSep "\n" (item: "  - ${item}") items;

    # Claude Code frontmatter (rich with tools, permissions, skills)
    claudeFrontmatter =
      let
        lines = [
          "---"
          "name: ${name}"
          "description: ${description}"
          "model: ${model}"
          "permissionMode: ${permissionMode}"
        ]
        ++ (optionals (tools != []) [ "tools:${yamlList tools}" ])
        ++ (optionals (disallowedTools != []) [ "disallowedTools:${yamlList disallowedTools}" ])
        ++ (optionals (skills != []) [ "skills:${yamlList skills}" ])
        ++ [ "---" ];
      in
      concatStringsSep "\n" lines;

    # OpenCode frontmatter (simple subagent mode)
    openCodeFrontmatter = ''
      ---
      mode: subagent
      ---
    '';
  in
  {
    inherit name description content model;

    # Claude Code: Rich frontmatter with all metadata
    toClaude = claudeFrontmatter + "\n\n" + content;

    # OpenCode: Minimal frontmatter (just mode: subagent)
    toOpenCode = openCodeFrontmatter + "\n" + content;
  };
}
