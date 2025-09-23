{ inputs, self, ... }:
let
  lib = import ../lib { inherit inputs self; };
in
{
  flake = {
    nixosConfigurations =
      lib.buildLinuxHosts {
        homura = "x86_64-linux";
        kyubey = "x86_64-linux";
      }
      // lib.buildWSLHosts {
        madoka = "x86_64-linux";
      };

    darwinConfigurations = lib.buildDarwinHosts {
      iroha = "aarch64-darwin";
    };
  };
}
