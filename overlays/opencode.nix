inputs: self: _super: {
  opencode = inputs.opencode.packages.${self.stdenv.hostPlatform.system}.default;
}
