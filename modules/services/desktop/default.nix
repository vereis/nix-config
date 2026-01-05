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

    altDrag = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Alt+drag to move/resize windows (inherited by desktop environments)";
    };
  };

  config = mkIf config.modules.services.desktop.autoLogin {
    # TTY autologin (for systems without display manager)
    services.getty.autologinUser = username;
  };

  imports = [
    ./gnome.nix
    ./graphics.nix
    ./niri.nix
    ./steam.nix
  ];
}
