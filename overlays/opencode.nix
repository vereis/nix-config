inputs: self: _super: {
  opencode = inputs.opencode.packages.${self.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace packages/opencode/src/index.ts \
        --replace-fail 'const marker = path.join(Global.Path.data, "opencode.db")' 'const marker = Database.Path'
    '';
  });
}
