_inputs: self: super: {
  # Override slack to use X11 by default to avoid white shadow border bug
  # See: https://github.com/electron/electron/issues/48570
  slack = self.symlinkJoin {
    name = "slack-x11";
    paths = [ super.slack ];
    buildInputs = [ self.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/slack \
        --set GDK_BACKEND x11 \
        --add-flags "--ozone-platform=x11" \
        --add-flags "--disable-features=UseOzonePlatform"

      # Fix .desktop file to use the wrapped binary
      rm $out/share/applications/slack.desktop
      substitute ${super.slack}/share/applications/slack.desktop $out/share/applications/slack.desktop \
        --replace-fail "${super.slack}/bin/slack" "$out/bin/slack"
    '';
  };
}
