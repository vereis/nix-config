{
  description = "Vereis' personal configurations for Linux, WSL, and MacOS";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
      nix-minecraft.url = "github:Infinidoge/nix-minecraft";
      zjstatus.url = "github:dj95/zjstatus";
      nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nix-homebrew = {
        url = "github:zhaofengli-wip/nix-homebrew";
      };
      homebrew-bundle = {
        url = "github:homebrew/homebrew-bundle";
        flake = false;
      };
      homebrew-core = {
        url = "github:homebrew/homebrew-core";
        flake = false;
      };
      homebrew-cask = {
        url = "github:homebrew/homebrew-cask";
        flake = false;
      };
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixos-wsl = {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs =
    inputs @ { home-manager
    , homebrew-bundle
    , homebrew-cask
    , homebrew-core
    , nix-darwin
    , nix-homebrew
    , nixpkgs-stable
    , nixos-wsl
    , nix-minecraft
    , nixpkgs
    , self
    , zjstatus
    , ...
    }:
    let
      # Config
      user = "vereis";
      username = "vereis";
      email = "me@vereis.com";

      # Configured Hosts
      windowsSystems = {};
      darwinSystems = { iroha = "aarch64-darwin"; };
      linuxSystems = { madoka = "x86_64-linux"; homura = "x86_64-linux"; kyubey = "x86_64-linux"; };

      # Secrets
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    in
    {
      darwinConfigurations =
        builtins.mapAttrs
          (hostname: system:
            nix-darwin.lib.darwinSystem {
              inherit system;
              specialArgs = { inherit (nixpkgs) lib; inherit inputs self system user username email zjstatus secrets; };
              modules = [
                ./machines/configuration.nix
                ./machines/darwin/configuration.nix
                ./machines/darwin/${hostname}
                home-manager.darwinModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit inputs user username email zjstatus secrets; };
                  home-manager.users.${user}.imports =
                    [ (import ./machines/home.nix) ] ++
                    [ (import ./machines/darwin/${hostname}/home.nix) ];
                }
                nix-homebrew.darwinModules.nix-homebrew
                {
                  nix-homebrew = {
                    user = username;
                    enable = true;
                    taps = {
                      "homebrew/homebrew-core" = homebrew-core;
                      "homebrew/homebrew-cask" = homebrew-cask;
                      "homebrew/homebrew-bundle" = homebrew-bundle;
                    };
                    mutableTaps = false;
                    autoMigrate = true;
                  };
                }
              ];
            }
          )
          darwinSystems;

      nixosConfigurations =
        (
	  builtins.mapAttrs
            (hostname: system:
              nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = {
                  inherit (nixpkgs) lib;
                  inherit inputs self system user username email zjstatus nix-minecraft secrets;
                  nixpkgs-stable = import nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
                modules = [
                  ./machines/configuration.nix
                  ./machines/linux/configuration.nix
                  ./machines/linux/${hostname}
                  home-manager.nixosModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = {
                      inherit inputs user username email zjstatus secrets;
                      nixpkgs-stable = import nixpkgs-stable {
                        inherit system;
                        config.allowUnfree = true;
                      };
                    };
                    home-manager.users.${user}.imports =
                      [ (import ./machines/home.nix) ] ++
                      [ (import ./machines/linux/${hostname}/home.nix) ];
                  }
                  {
                    imports = [ nix-minecraft.nixosModules.minecraft-servers ];
                  }
                ];
              }
            )
            linuxSystems
	) // (
          builtins.mapAttrs
            (hostname: system:
              nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = {
                  inherit (nixpkgs) lib;
                  inherit inputs self system user username email zjstatus nix-minecraft secrets;
                };
                modules = [
                  nixos-wsl.nixosModules.wsl
                  ./machines/configuration.nix
                  ./machines/windows/configuration.nix
                  ./machines/windows/${hostname}
                  home-manager.nixosModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = { inherit inputs user username email zjstatus secrets; };
                    home-manager.users.${user}.imports =
                      [ (import ./machines/home.nix) ] ++
                      [ (import ./machines/windows/${hostname}/home.nix) ];
                  }
                  {
                    imports = [ nix-minecraft.nixosModules.minecraft-servers ];
                  }
                ];
              }
            )
            windowsSystems
	);
    };
}
