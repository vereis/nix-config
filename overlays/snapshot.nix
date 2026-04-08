_: _: prev: {
  # Global Snapshot wrapper to avoid GTK/Vulkan crashes on some Intel systems.
  snapshot = prev.symlinkJoin {
    name = "snapshot-safe";
    paths = [ prev.snapshot ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      rm -f "$out/share/dbus-1/services/org.gnome.Snapshot.service"
      cat > "$out/share/dbus-1/services/org.gnome.Snapshot.service" <<EOF
      [D-BUS Service]
      Name=org.gnome.Snapshot
      Exec=$out/bin/snapshot --gapplication-service
      EOF

      wrapProgram $out/bin/snapshot \
        --set GSK_RENDERER cairo \
        --set GDK_DISABLE vulkan
    '';
  };
}
