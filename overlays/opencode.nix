final: prev: {
  # OpenCode package
  # TODO: Replace with actual OpenCode package when available
  # For now, this is a placeholder that would allow the module to work
  opencode = prev.writeShellScriptBin "opencode" ''
    echo "OpenCode placeholder - replace with actual package"
    echo "OpenCode would be installed here if available"
    exit 1
  '';
}
