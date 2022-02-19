# My Nix/NixOS Configuration

## Installation

Note that the only requirements for this configuration are [Nix](https://nixos.org/download.html#download-nix) (or alternatively, [NixOS](https://nixos.org/download.html#nixos-iso)), [home-manager](https://github.com/nix-community/home-manager), and [git](https://git-scm.com/).

If you're bootstrapping a NixOS configuration, you may not have the latter installed. It is recommended to install it temporarily for the initial setup via `nix-shell -p git` to prevent any potential issues using `nix-env`.

If you _do_ end up running into issues, you may need to use `nix-env --set-flag priority <integer> git`, as this configuration tries to manage its own installation of git.

Unless you're installing this on [NixOS](https://nixos.org/download.html#nixos-iso), you'll first need to install [Nix (the package manager)](https://nixos.org/download.html#download-nix). You can do this quickly via running the following:

```sh
curl -L https://nixos.org/nix/install | sh
```

Following this, install [home-manager](https://github.com/nix-community/home-manager):

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

After this is done, you're more or less done. The only thing remaining is to _"activate"_ this configuration. The way we do this differs on whether or not you're installing on NixOS.

If you _are_ using NixOS then you'll need configure your `/etc/nixos/configuration.nix` to look similar to `./configuration.nix` (or even symlink it). If you're going to be adapting your own `/etc/nixos/configuration.nix` manually, then feel free to opt out of using the reusable `hardware/` modules in lieu of your own custom configuration.

If you do choose to use the reusable `hardware/` modules, the only neccessary non-`hardware/` or `modules/` configuration lines you'll need to set pertain either to your machine's hostname, timezone, boot configuration, networking, or hardware configuration. Everything else should be handlable via modules.

If you're just using Nix without NixOS, then you can skip the above steps and simply symlink your intended configuration to `~/.config/nixpkgs/home.nix` like so:

```sh
rm ~/.config/nix/home.nix
ln -s $(pwd)/machines/<profile>.nix $HOME/.config/nixpkgs/home.nix
```

## Configuration Layout

- Everything inside of `modules/` is a re-usable module that installs and/or configures applications that you expect to be installed for your current user. This is where the bulk of configuration lies.
    Notable modules include:
    - Fetching and installing my Vim configuration
    - Installing my expected standard set of tools, such as fzf or httpie
    - Installing web browsers, steam, any other programs I wish to run
- Everything inside of `hardware/` is a re-usable module which sets NixOS specific configuration as these cannot currently be set from inside `modules/`. This is because all `modules/` are in the purview of home-manager rather than NixOS.

    Note that this means that no `hardware/` modules are usable _without_ a NixOS installation. If you're installing my configuration on WSL or atop another standard Linux distribution, one would expect any configuration to be managed the way expected by the host system.

    Notable modules include:
    - Enabling bluetooth
    - Activating nvidia or amd GPU drivers
    - Setting keyboard key-repeat and delay
    - Configuring mouse acceleration and sensitivitj
- Configuration files inside `machines/` simply compose `modules/` modules. You can think of these as discrete hosts (though in my case, I re-use `machines/tteokbokki.nix` for a WSL installation, as well as my NixOS workstation installation). These files **cannot** use `hardware/` modules at the moment, but work is being done to enable this.
- Configuration files inside `profiles/` are meant to classify the "class" of Nix/NixOS installation (i.e. whether its a VM, Laptop, Workstation, WSL2 container). This isn't being used very optimally at the moment and can probably be removed.
