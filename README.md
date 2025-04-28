# Dotfiles

Install Nix (preferably using Determinate Nix Installer)

Clone Repo
```
git clone git@github.com:tansanrao/dotfiles.git ~/.dotfiles
```

For Linux:
```
nix run home-manager/release-24.11 -- switch --flake ~/.dotfiles
```
