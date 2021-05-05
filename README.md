# initial installation
install nix:
```sh
curl -L https://nixos.org/nix/install | sh
```

install home-manager:
```sh
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

then just link home-manager config to `~/.config/nixpkgs/home.nix` via:

```sh
rm ~/.config/nix/home.nix
ln -s <$pwd>/<PROFILE.nix> <$home-dir>/.config/nix/home.nix
```

`home-manager switch`

# Misc

Note, these files have a hard requirement on `git` being available. It usually
isn't an issue if `git` is installed via your host OS, but if you installed
`git` via `nix-env`, then you'll need to run:

```nix
nix-env --set-flag priority 999 git
```

This will enable `home-manager` to override `git`, thus meaning that it'll use
the original `git` binary _until_ `home-manager` manages to install its own
copy. Once this is done, this config should be wholly self sufficient.
