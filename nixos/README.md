# Personal NixOS Configuration files

This repo is almost always going to be in a state of flux as I play around and try new things in NixOS.

The configuration/layout/idioms here may not be suitable for 'production' use, so try not to copy these files ad hoc.

Note that when installing any of these on a new NixOS installation, you need to have `git` available, so install that manually first.

## Usage
This repo is intended to be cloned to `/etc/nixos`.

A NixOS install's `configuration.nix` and `hardware-configuration.nix` are ignored by this repo.

A sample `configuration.nix` might want to look like the following:

```nix
{ config, pkgs, ... }:

{
  imports =
    [ 
      ./machines/<HOSTNAME>.nix
      ./hardware-configuration.nix
    ];

  boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
```

For my usage, `hardware-configuration.nix` is always auto-generated.

### Machines

Inside the `machines/` directory are files which contain configuration of different machines. Setting up a new machine is as simple as importing `./machines/<HOSTNAME>.nix` in your system's `configuration.nix`.

Nix modules in the `machines/` directory contain configuration of different machines I use, as well as packages installed in the system/home when they really don't need to be shared or further abstracted to different machines (i.e. a game I'm playing, or a chat app that I don't configure and only use once between all my machines).

Nix modules in the `machines/` directory should contain minimal configuration of `services.xserver`, applications and otherwise should only import nix modules from the `profiles/` directory or `modules/` directory.

### Profiles

Inside the `profiles/` directory are files which contain base configuration for classifications of machines. Right now I only have a handful, but as time goes on the idea is to implement a `workstation.nix`, `laptop.nix`, `tablet.nix` etc which contain tools I'd expect to be installed only for those machine classes (i.e. I might opt out to have battery monitoring on a `workstation.nix` or `desktop.nix` but want that module auto-loaded in `laptop.nix` or `tablet.nix`).

All profiles are expected to include `base.nix` which contains what I view as a few locale configurations that I'd want on all machines, as well as some base packages I'd expect to be installed (such as `home-manager`).

### Modules

Inside the `modules/` directory are files which enable/add packages to the system package list or home package list. I've yet to devise a way of doing the latter in a clean way, so all modules expect a user named `Chris` to be configured... I intend on revisiting this.

These can be services, packages or really anything else (see `amd_gpu.nix` or `nur.nix`) but the idea is to abstract this stuff away.

Modules implemeted here ought to have a `modules.<module>.enable` boolean option defined since hopefully I'd want to auto-import the contents of this directory.

See `neovim.nix` or `kitty.nix` for more complex use-cases where I've split these out primarily to abstract away a lot of configuration (and hackiness in the case of `neovim.nix`). Other modules are far simpler and arguably could stay in a `machine/<hostname>.nix` file or `profile/<class>.nix` file but for consistency I'd like to aim for everything to be a module I can simply enable.
