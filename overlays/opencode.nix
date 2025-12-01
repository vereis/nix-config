inputs: self: _super: {
  opencode = inputs.opencode.packages.${self.system}.default;
}
