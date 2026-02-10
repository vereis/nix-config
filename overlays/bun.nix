_inputs: _final: prev:
let
  # opencode (sst/opencode) currently requires bun >= 1.3.8.
  bunSources_1_3_8 = {
    "x86_64-linux" = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.8/bun-linux-x64.zip";
      hash = "sha256-AyKxfwci2namQpiq1JgiWu3L9t8QCKHe5F4W7LImo/E=";
    };
    "aarch64-linux" = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.8/bun-linux-aarch64.zip";
      hash = "sha256-Tp3raBSn7H9ocl3dl9DXtAZbzamoUPadSXVn6ZWn+jM=";
    };
  };
in
{
  bun = prev.bun.overrideAttrs (
    old:
    let
      inherit (prev.stdenvNoCC.hostPlatform) system;
    in
    {
      __intentionallyOverridingVersion = true;
      version = "1.3.8";

      # Important: override src too, otherwise the output bun binary stays at the old version.
      src = bunSources_1_3_8.${system} or old.src;

      passthru = (old.passthru or { }) // {
        sources = bunSources_1_3_8;
      };
    }
  );
}
