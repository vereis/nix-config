_inputs: self: super: {
  # Override teams-for-linux to use X11 by default for consistent titlebars
  teams-for-linux = self.symlinkJoin {
    name = "teams-for-linux-x11";
    paths = [ super.teams-for-linux ];
    buildInputs = [ self.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/teams-for-linux \
        --set GDK_BACKEND x11 \
        --add-flags "--ozone-platform=x11" \
        --add-flags "--disable-features=UseOzonePlatform"

      # Fix .desktop file to use the wrapped binary
      rm $out/share/applications/teams-for-linux.desktop
      substitute ${super.teams-for-linux}/share/applications/teams-for-linux.desktop $out/share/applications/teams-for-linux.desktop \
        --replace-fail "Exec=teams-for-linux" "Exec=$out/bin/teams-for-linux"
    '';
  };
}
