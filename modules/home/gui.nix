{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkOption mkIf types;
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  options.modules.gui = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enables GUI applications and configuration.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional GUI packages.";
    };

    extraFiles = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description = "Extra files to create in the home directory. Accepts any valid home-manager file attributes.";
    };

    extraSessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra session variables to set. Use this for machine-specific secrets and configuration.";
    };
  };

  config = mkIf config.modules.gui.enable {
    home = {
      packages =
        with pkgs;
        [
          inter
          maple-mono.NF
          onlyoffice-desktopeditors
          discord
        ]
        ++ config.modules.gui.extraPackages;

      file = config.modules.gui.extraFiles;

      sessionVariables = {
        BROWSER = "zen-twilight";
        DEFAULT_BROWSER = "zen-twilight";
      }
      // config.modules.gui.extraSessionVariables;
    };

    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        background = "060606";
        foreground = "e0def4";
        cursor-color = "524f67";
        selection-background = "2a283e";
        selection-foreground = "e0def4";
        font-family = "Maple Mono NF";
        font-size = 12;
        window-padding-x = 32;
        window-padding-y = 32;
        window-padding-balance = true;
        cursor-style = "block";
        cursor-style-blink = true;
        shell-integration-features = "no-cursor";

        # Enable clickable links
        link-url = true;
        mouse-shift-capture = false;

        # Enable image protocols (Kitty image protocol)
        image-storage-limit = 320000000;

        # Copy on select
        copy-on-select = true;

        # Mouse behavior
        mouse-hide-while-typing = true;

        # Clipboard settings
        clipboard-read = "ask";
        clipboard-write = "allow";
        clipboard-paste-protection = true;
      };
    };

    programs.zen-browser = {
      enable = true;

      policies =
        let
          mkLockedAttrs = builtins.mapAttrs (
            _: value: {
              Value = value;
              Status = "locked";
            }
          );
        in
        {
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisablePocket = true;
          DisableFirefoxStudies = true;
          DisableFeedbackCommands = true;
          NoDefaultBookmarks = true;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = true;

          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };

          Preferences = mkLockedAttrs {
            "browser.tabs.warnOnClose" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "font.name.serif.x-western" = "Inter Display";
            "font.name.sans-serif.x-western" = "Inter Display";
            "font.name.monospace.x-western" = "Maple Mono NF";
          };
        };

      profiles."default" = {
        id = 0;
        isDefault = true;

        search = {
          default = "Kagi";
          force = true;
          engines = {
            "Kagi" = {
              urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
              definedAliases = [ "@k" ];
            };
            "amazon-uk" = {
              urls = [ { template = "https://www.amazon.co.uk/s?k={searchTerms}"; } ];
              definedAliases = [ "!a" ];
            };
            "elixir-docs" = {
              urls = [ { template = "https://hexdocs.pm/elixir/search.html?q={searchTerms}"; } ];
              definedAliases = [ "!ex" ];
            };
            "oban-docs" = {
              urls = [ { template = "https://hexdocs.pm/oban/search.html?q={searchTerms}"; } ];
              definedAliases = [ "!oban" ];
            };
            "ecto-docs" = {
              urls = [ { template = "https://hexdocs.pm/ecto/search.html?q={searchTerms}"; } ];
              definedAliases = [ "!ecto" ];
            };
            "github" = {
              urls = [ { template = "https://github.com/search?o=desc&q={searchTerms}&s=stars"; } ];
              definedAliases = [ "!gh" ];
            };
            "github-gist" = {
              urls = [ { template = "https://gist.github.com/search?q={searchTerms}"; } ];
              definedAliases = [ "!gist" ];
            };
            "google" = {
              urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
              definedAliases = [ "!g" ];
            };
            "google-images" = {
              urls = [ { template = "https://www.google.com/search?tbm=isch&q={searchTerms}&tbs=imgo:1"; } ];
              definedAliases = [ "!gi" ];
            };
            "google-maps" = {
              urls = [ { template = "https://www.google.com/maps/search/{searchTerms}"; } ];
              definedAliases = [ "!gm" ];
            };
            "reddit" = {
              urls = [ { template = "https://www.reddit.com/search?q={searchTerms}"; } ];
              definedAliases = [ "!r" ];
            };
            "wikipedia" = {
              urls = [ { template = "https://en.wikipedia.org/wiki/{searchTerms}"; } ];
              definedAliases = [ "!w" ];
            };
            "youtube" = {
              urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
              definedAliases = [ "!yt" ];
            };
          };
        };

        containersForce = true;
        containers = {
          Personal = {
            color = "purple";
            icon = "fingerprint";
            id = 1;
          };
          Work = {
            color = "blue";
            icon = "briefcase";
            id = 2;
          };
          Entertainment = {
            color = "pink";
            icon = "fruit";
            id = 3;
          };
        };

        spacesForce = true;
        spaces = {
          "Default" = {
            id = "ec991822-6062-4d1f-bbb7-8db739339eb7";
            icon = "🏠";
            container = 1;
            position = 1000;
          };
          "Work" = {
            id = "b5470b32-b9b3-4c4a-a5ee-d7de94bbfa43";
            icon = "💼";
            container = 2;
            position = 2000;
          };
          "Entertainment" = {
            id = "d66075c8-c773-4a68-8ac1-4921c9c0bba2";
            icon = "🍑";
            container = 3;
            position = 3000;
          };
        };
      };
    };

    xdg.mimeApps =
      let
        zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
        value = zen-browser.meta.desktopFileName;

        associations = builtins.listToAttrs (
          map
            (name: {
              inherit name value;
            })
            [
              "application/x-extension-shtml"
              "application/x-extension-xhtml"
              "application/x-extension-html"
              "application/x-extension-xht"
              "application/x-extension-htm"
              "x-scheme-handler/unknown"
              "x-scheme-handler/mailto"
              "x-scheme-handler/chrome"
              "x-scheme-handler/about"
              "x-scheme-handler/https"
              "x-scheme-handler/http"
              "application/xhtml+xml"
              "application/json"
              "text/plain"
              "text/html"
            ]
        );
      in
      {
        associations.added = associations;
        defaultApplications = associations;
      };
  };
}
