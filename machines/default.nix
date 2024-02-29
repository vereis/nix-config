{ lib, inputs, nixpkgs, home-manager, nixos-wsl, zjstatus, username, ... }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  lib = nixpkgs.lib;
in
{
  # Workstation PC
  madoka = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username zjstatus; };
    modules = [
      ./madoka
      ./configuration.nix
      nixos-wsl.nixosModules.wsl
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit username zjstatus; };
        home-manager.users.${username}.imports = [(import ./home.nix)] ++ [(import ./madoka/home.nix)];
      }
    ];
  };

  # Dell XPS 13 4K
  homura = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username zjstatus; };
    modules = [
      ./homura
      ./configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit username zjstatus; };
        home-manager.users.${username}.imports = [(import ./home.nix)] ++ [(import ./homura/home.nix)];
      }
    ];
  };

  # Server / Homelab
  kyubey = lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs username zjstatus; };
    modules = [
      ./kyubey
      ./configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit username zjstatus; };
        home-manager.users.${username}.imports = [(import ./home.nix)] ++ [(import ./kyubey/home.nix)];
      }
    ];
  };
}
