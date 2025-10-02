# Nix Configuration

This is my personal Nix configuration for Windows (WSL), Linux (NixOS), and macOS (nix-darwin).

It uses **flake-parts** to help with organization and modularity (especially for multi-platform support):

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
│   │   └── kyubey/
│   ├── darwin/                  ## MacOS machine configurations
│   │   ├── configuration.nix
│   │   └── iroha/
│   ├── wsl/                     ## WSL2 machine configurations
│   │   ├── configuration.nix
│   │   └── homura/
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
├── secrets/                     # Encrypted secrets
└── bin/                         # Custom scripts, utilities
```

Installation starts at the top level `flake.nix`, which uses `lib/default.nix` and `parts/hosts.nix` to build configurations for each platform I support.

Each host configuration then gets configured via `hosts/<platform>/configuration.nix` and `hosts/<platform>/<hostname>/`, which pulls in reusable modules from `modules/`.

## Usage

1. Clone this repository
1. Install `nix` (ideally via Determinate Systems) or `nixos`
1. Decrypt secrets with `git-crypt`:
   ```bash
   git-crypt unlock <path-to-key>
   ```
1. Install:
   ```bash
   sudo nixos-rebuild switch --flake .#<machine-name>
   darwin-rebuild switch --flake .#<machine-name>
   ```
