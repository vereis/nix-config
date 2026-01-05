{
  lib,
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
in
{
  options.modules.services.desktop = {
    autoLogin = mkOption {
      type = types.bool;
      default = false;
      description = "Enable autologin for both TTY and display manager (uses username from config)";
    };

    # NOTE: altDrag is not applicable to niri - niri uses Mod+drag for move/resize by default.
    # This option is kept for potential future use with other desktop environments.
  };

  config = mkIf config.modules.services.desktop.autoLogin {
    # TTY autologin (for systems without display manager)
    services.getty.autologinUser = username;
  };

  imports = [
    ./gnome.nix
    ./graphics.nix
    ./steam.nix
    ./niri.nix
  ];
}
