inputs: self: _super: {
  opencode = inputs.opencode.packages.${self.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace package.json \
        --replace-fail '"packageManager": "bun@1.3.14"' '"packageManager": "bun@1.3.13"'
    '';
  });
}
