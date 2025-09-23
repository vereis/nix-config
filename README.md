# Nix Configuration

This is my personal Nix configuration for Windows (WSL), Linux (NixOS), and macOS (nix-darwin).

It uses **flake-parts** to help with organization and modularity (especially for multi-platform support).

## Structure

```
├── flake.nix          # Main flake configuration using flake-parts
├── lib/               # Core builder functions and utilities
│   └── default.nix    # Platform-specific system builders
├── parts/             # Flake-parts modules
│   ├── devshell.nix   # Development shell configuration
│   ├── formatter.nix  # Code formatting (treefmt-nix)
│   ├── hosts.nix      # Host system definitions
│   └── overlays.nix   # Package overlays
├── hosts/             # Host configurations
│   ├── linux/         # Linux/NixOS base configuration
│   │   ├── configuration.nix  # Shared Linux configuration
│   │   ├── homura/    # Linux machine "homura"
│   │   └── kyubey/    # Linux machine "kyubey"
│   ├── darwin/        # macOS configurations
│   │   ├── configuration.nix  # Darwin base configuration
│   │   └── iroha/     # macOS machine "iroha"
│   ├── wsl/           # WSL configurations
│   │   ├── configuration.nix  # WSL base (inherits from linux/configuration.nix)
│   │   └── madoka/    # WSL machine "madoka"
│   └── home.nix       # Shared home-manager configuration
└── secrets/           # Encrypted secrets (git-crypt)
```

## Usage

### Initial Setup

1. Clone this repository
2. Ensure you have Nix with flakes enabled
3. For secrets, set up git-crypt:
   ```bash
   git-crypt unlock
   ```

### Building Configurations

```bash
sudo nixos-rebuild switch --flake .#<machine-name>
darwin-rebuild switch --flake .#<machine-name>
```
