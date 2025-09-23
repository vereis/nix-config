# Nix Configuration

A comprehensive NixOS and nix-darwin configuration setup with modular machine-specific configurations and home-manager integration.

## Structure

```
├── machines/           # Machine-specific configurations
│   ├── darwin/        # macOS configurations
│   │   └── iroha/     # macOS machine named "iroha"
│   ├── linux/         # Linux configurations
│   │   ├── homura/    # Linux machine named "homura"
│   │   └── kyubey/    # Linux machine named "kyubey"
│   └── windows/       # Windows configurations
│       └── madoka/    # Windows machine named "madoka"
├── modules/           # Reusable configuration modules
│   ├── hardware/      # Hardware-specific modules
│   ├── home/          # Home-manager modules
│   │   ├── gui/       # GUI applications and settings
│   │   └── tui/       # Terminal applications and settings
│   └── services/      # System services configurations
├── overlays/          # Nix package overlays
└── secrets/           # Encrypted secrets (git-crypt)
```

## Machines

### Linux

- **homura**: Linux workstation configuration
- **kyubey**: Linux server configuration

### macOS

- **iroha**: macOS configuration with nix-darwin

### Windows

- **madoka**: Windows configuration with nix support

## Modules

### Home Manager

- **GUI**: Desktop applications, window managers, and graphical tools
- **TUI**: Terminal applications including:
  - Neovim with extensive plugin configuration
  - Zsh shell setup
  - Git configuration
  - Zellij terminal multiplexer

### Services

- **Media Server Stack**: Jellyfin, Sonarr, Radarr, Lidarr, Readarr
- **Network**: Tailscale, Proxy, FlareSolverr
- **System**: GPG, Printing, Transmission
- **Gaming**: Minecraft server
- **Package Management**: Winget proxy

### Hardware

- HHKB keyboard support
- GPU customization

## Usage

### Initial Setup

1. Clone this repository
1. Ensure you have Nix with flakes enabled
1. For secrets, set up git-crypt:
   ```bash
   git-crypt unlock
   ```

### Building Configurations

#### NixOS (Linux)

```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<machine-name>

# Example for homura machine
sudo nixos-rebuild switch --flake .#homura
```

#### nix-darwin (macOS)

```bash
# Build and switch to configuration
darwin-rebuild switch --flake .#<machine-name>

# Example for iroha machine
darwin-rebuild switch --flake .#iroha
```

## Features

- **Modular Design**: Easily share configurations between machines
- **Multi-Platform**: Support for Linux, macOS, and Windows
- **Encrypted Secrets**: Secure secret management with git-crypt
- **Rich Development Environment**: Comprehensive Neovim setup with LSP, completion, and modern plugins
- **Media Server**: Complete \*arr stack for media management
- **Networking**: Tailscale integration for secure remote access

## Development Tools

### Neovim Configuration

Located in `modules/home/tui/neovim/`, featuring:

- LSP integration with multiple language servers
- Completion with nvim-cmp
- Git integration with gitsigns
- File explorer with neo-tree
- Fuzzy finding with telescope
- AI assistance with Avante and Copilot
- Modern UI with various quality-of-life plugins

### Shell Setup

- Zsh with custom configuration
- Git helpers and aliases
- Terminal multiplexing with Zellij

## Security

### Current: git-crypt

This configuration currently uses git-crypt for managing secrets. While functional, git-crypt has several limitations:

- **Plain-Text Secrets at Rest**: Secrets are stored in plain text in the repository, and in the `/nix/store`.
- **Single Key Management**: All secrets are encrypted with a single key, making it difficult to manage access permissions.
- **Limited Integration**: Secrets are not integrated into the Nix evaluation process, requiring manual handling.

### Future: agenix

Planning to migrate to [agenix](https://github.com/ryantm/agenix) when more advanced secret management is needed:

- **Per-secret encryption**: Each secret can have different access permissions
- **Nix integration**: Secrets are decrypted during evaluation and available as derivations
- **Age-based**: Uses modern age encryption instead of GPG
- **Machine-specific**: Secrets can be targeted to specific machines/users
- **Better UX**: Integrated tooling for secret management
- **Plug and Play**: Should just work with `nixos-rebuild --switch`

## TODO

- [ ] Migrate from git-crypt to agenix for better secret management
- [ ] Add more comprehensive documentation for each service module
- [ ] Set up automated testing for configurations
- [ ] Implement backup strategies
- [ ] Add continuous integration for configuration validation
- [ ] Automatic updates in CI for new `nixpkgs/unstable` releases
