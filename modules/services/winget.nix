{ pkgs, lib, config, ... }:

with lib;
{
  options.modules.winget = {
    enable = mkOption { type = types.bool; default = false; };
    packages = mkOption {
      type = types.listOf types.str;
      default = [];
      example = literalExpression "[ \"AutoHotkey.AutoHotkey\" ]";
      description = ''
        List of packages to install via winget.exe
        You can find packages via `winget.exe search`
      '';
    };
  };

  config = mkIf config.modules.winget.enable {
    home.file.".config/winget/manifest.json" = {
      text = ''
        {
          "$schema": "https://aka.ms/winget-packages.schema.2.0.json",
          "CreationDate": "2025-03-11T12:26:36.313-00:00",
          "Sources":
          [
            {
              "Packages":
              [
                ${
                  lib.concatMapStringsSep "\n" (pkg: ''
                    { "PackageIdentifier" : "${pkg}" },
                  '') config.modules.winget.packages
                }
              ],
              "SourceDetails":
              {
                "Argument" : "https://cdn.winget.microsoft.com/cache",
                "Identifier" : "Microsoft.Winget.Source_8wekyb3d8bbwe",
                "Name" : "winget",
                "Type" : "Microsoft.PreIndexed.Package"
              }
            },
          ],
          "WinGetVersion" : "1.10.340"
        }
      '';
    };

    home.activation.winget = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run /mnt/c/Users/vereis/AppData/Local/Microsoft/WindowsApps/winget.exe import $(/bin/wslpath -m $HOME/.config/winget/manifest.json) || true
    '';
  };
}
