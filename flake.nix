{
  description = "My Personal NixOS Configuration Files";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      username = "chris";
    in
    {
      nixosConfigurations = (
        import ./machines { inherit (nixpkgs) lib; inherit inputs nixpkgs home-manager username; }
      );
    };
}
