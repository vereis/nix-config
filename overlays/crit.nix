inputs: self: _super: {
  crit = inputs.crit.packages.${self.stdenv.hostPlatform.system}.default;
}
