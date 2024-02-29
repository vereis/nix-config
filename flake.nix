{
  description = "My Personal NixOS Configuration Files";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      zjstatus.url = "github:dj95/zjstatus";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixos-wsl = {
        url = "github:nix-community/NixOS-WSL";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, nixos-wsl, zjstatus, home-manager, ... }:
    let
      username = "chris";
    in
    {
      nixosConfigurations = (
        import ./machines { inherit (nixpkgs) lib; inherit inputs nixpkgs home-manager nixos-wsl username zjstatus; }
      );
    };
}
