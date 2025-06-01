# NOTE: as of 2024-08-16, the `delta` package in nixpgs unstable cannot be built under rust 1.80
#       per dicussion in https://github.com/rust-lang/rust/issues/127343
#
#       looks like this has been fixed upstream but is not released yet, so just override the
#       pkg to build from latest commit as of date.
self: super:
let
  version = "0.17.0";
  src = super.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "1f6cc721580064afdd84048c37ff9d0eb5f44001";
    sha256 = "sha256-y0VCGmqnWVKYW+DUWiAI45IxIrzzv2XFL+V4a4sxJi8=";
  };
in
{
  delta = super.delta.overrideAttrs (drv: {
    inherit version src;
    cargoDeps = drv.cargoDeps.overrideAttrs (super.lib.const {
      inherit src;
      name = "delta-vendor.tar.gz";
      outputHash = "sha256-QwBhtIddxkf2uVWBsYZRZ1EVOe7L8v31xK2ihhvCDlo=";
    });
  });
}
