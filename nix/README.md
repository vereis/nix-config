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
