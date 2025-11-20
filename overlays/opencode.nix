inputs: self: super: {
  opencode = inputs.opencode.packages.${self.system}.default;
}
