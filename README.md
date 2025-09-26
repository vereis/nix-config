# Nix Configuration

This is my personal Nix configuration for Windows (WSL), Linux (NixOS), and macOS (nix-darwin).

It uses **flake-parts** to help with organization and modularity (especially for multi-platform support) and **agenix** for managing secrets:

```
├── flake.nix
├── lib/                         # Utility functions
│   └── default.nix
├── parts/                       # Flake parts
│   ├── devshell.nix
│   ├── formatter.nix
│   ├── hosts.nix
│   └── overlays.nix
├── hosts/                       # Host-specific configurations
│   ├── linux/                   ## NixOS machine configurations
│   │   ├── configuration.nix
│   │   ├── homura/
│   │   └── kyubey/
│   ├── darwin/                  ## MacOS machine configurations
│   │   ├── configuration.nix
│   │   └── iroha/
│   ├── wsl/                     ## WSL2 machine configurations
│   │   ├── configuration.nix
│   │   └── madoka/
│   └── home.nix
├── modules/                     # Reusable modules
│   ├── hardware/                ## Hardware-specific modules
│   ├── home/                    ## User-specific modules, applications
│   │   ├── gui/
│   │   ├── tui/
│   │   ├── gui.nix              ## GUI applications
│   │   └── tui.nix              ## TUI applications
│   └── services/                ## Background service modules
├── overlays/                    # Overlays
├── keys/                        # Public keys for agenix
├── secrets/                     # Encrypted secrets for agenix
├── secrets.nix                  # agenix configuration
└── bin/                         # Custom scripts, utilities
```

Installation starts at the top level `flake.nix`, which uses `lib/default.nix` and `parts/hosts.nix` to build configurations for each platform I support.

Each host configuration then gets configured via `hosts/<platform>/configuration.nix` and `hosts/<platform>/<hostname>/`, which pulls in reusable modules from `modules/`.

## Installation

1. Clone this repository
1. Install `nix` (ideally via Determinate Systems) or `nixos`
1. Install:
   ```bash
   # For Linux/WSL hosts
   sudo nixos-rebuild switch --flake .#<machine-name>
   # For macOS hosts
   darwin-rebuild switch --flake .#<machine-name>
   ```

## Secrets

Secrets are managed via `agenix` and automatically decrypted on each system using SSH keys.

To edit secrets:

```bash
agenix -e <secret-name>.age
```

To decrypt a secret manually:

```bash
agenix -d <secret-name>.age
```

All secrets are defined in `secrets.nix` and encrypted files are stored in `secrets/`.

## Development

- Format code: `nix fmt`
- Lint code: `statix`
- Dead code elimination: `deadnix`
- Test configurations: `nix build '.#nixosConfigurations.<host>.config.system.build.toplevel' --dry-run`
