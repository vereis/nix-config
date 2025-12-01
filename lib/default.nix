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
    # Use dummy secrets in CI (when git-crypt is not unlocked)
    # Set NIX_CONFIG_USE_DUMMY_SECRETS=1 environment variable to use dummy secrets
    if (builtins.getEnv "NIX_CONFIG_USE_DUMMY_SECRETS") == "1" then
      {
        anthropic.apiKey = "sk-ant-dummy-key";
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
        vetspire = {
          gitEmail = "dummy@example.com";
          jiraApiKey = "dummy-jira-key";
        };
        gemini-cli = {
          googleCloudProject = "dummy-project";
          apiKey = "dummy-gemini-key";
        };
      }
    else
      builtins.fromJSON (builtins.readFile ../secrets/secrets.json);

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
