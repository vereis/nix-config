{
  inputs,
  self ? inputs.self or null,
}:
let
  inherit (inputs)
    nixpkgs
    nixpkgs-stable
    home-manager
    nix-darwin
    nixos-wsl
    ;

  userConfig = {
    user = "vereis";
    username = "vereis";
    email = "me@vereis.com";
  };

  secrets =
    let
      secretsFile = ../secrets/secrets.json;
      # Check if secrets file is readable (not encrypted or missing)
      secretsContent = builtins.tryEval (builtins.readFile secretsFile);
    in
    if secretsContent.success then
      builtins.fromJSON secretsContent.value
    else
      # Provide dummy secrets for CI or when git-crypt is not unlocked
      {
        cloudflare.ddclient = "dummy-cloudflare-token";
        minecraft.minnacraft = {
          rcon = {
            password = "dummy-rcon-password";
            port = 25575;
          };
        };
        copyparty = {
          vereis = "dummy-vereis-password";
          turtz = "dummy-turtz-password";
        };
        vetspire.gitEmail = "dummy@example.com";
      };

  mkSpecialArgs =
    system:
    userConfig
    // {
      inherit (nixpkgs) lib;
      inherit
        inputs
        self
        system
        secrets
        ;
      inherit (inputs) zjstatus copyparty;
      nixpkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    };

  mkHomeManagerConfig =
    {
      hostname,
      platform,
      system,
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = userConfig // {
          inherit inputs secrets;
          inherit (inputs) zjstatus;
          nixpkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        users.${userConfig.user}.imports = [
          (import ../hosts/home.nix)
          (import ../hosts/${platform}/${hostname}/home.nix)
        ];
      };
    };

  platformModules = {
    linux = hostname: [
      ../hosts/linux/configuration.nix
      ../hosts/linux/${hostname}
      inputs.copyparty.nixosModules.default
      inputs.nix-minecraft.nixosModules.minecraft-servers
      {
        imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
        nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
      }
    ];

    darwin = hostname: [
      ../hosts/darwin/configuration.nix
      ../hosts/darwin/${hostname}
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          user = userConfig.username;
          enable = true;
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          };
          mutableTaps = false;
          autoMigrate = true;
        };
      }
    ];

    wsl = hostname: [
      nixos-wsl.nixosModules.wsl
      ../hosts/wsl/configuration.nix
      ../hosts/wsl/${hostname}
    ];
  };

  buildHost =
    {
      systemBuilder,
      homeManager,
      platform,
    }:
    hosts:
    builtins.mapAttrs (
      hostname: system:
      systemBuilder {
        inherit system;
        specialArgs = mkSpecialArgs system;
        modules = platformModules.${platform} hostname ++ [
          homeManager
          (mkHomeManagerConfig { inherit hostname platform system; })
        ];
      }
    ) hosts;
in
{
  buildLinuxHosts = buildHost {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManager = home-manager.nixosModules.home-manager;
    platform = "linux";
  };

  buildDarwinHosts = buildHost {
    systemBuilder = nix-darwin.lib.darwinSystem;
    homeManager = home-manager.darwinModules.home-manager;
    platform = "darwin";
  };

  buildWSLHosts = buildHost {
    systemBuilder = nixpkgs.lib.nixosSystem;
    homeManager = home-manager.nixosModules.home-manager;
    platform = "wsl";
  };
}
