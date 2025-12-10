{ inputs, self, ... }:
let
  lib = import ../lib { inherit inputs self; };
in
{
  flake = {
    nixosConfigurations =
      lib.buildLinuxHosts {
        kyubey = "x86_64-linux";
        madoka = "x86_64-linux";
      }
      // lib.buildWSLHosts {
        homura = "aarch64-linux";
      };

    darwinConfigurations = lib.buildDarwinHosts {
      iroha = "aarch64-darwin";
    };
  };
}
