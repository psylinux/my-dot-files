# My Dot Files

Dotfiles for Linux and macOS managed with GNU Stow.

## Layout
- `stow/common`: shared settings (global `.gitignore`).
- `stow/linux`: Linux shell/editor/git/tmux configs plus helper scripts in `.local/bin`.
- `stow/mac`: macOS zsh/tmux/git configs and GPG agent files.
- `scripts/linux`: one-off setup helpers (`vim-setup.sh`) run manually.
- `scripts/bootstrap-*.sh`: platform-specific bootstrap entrypoints called by `install.sh`.
- `Makefile`: shortcuts for linting, dry-run stow, and bootstrapping.

## Using Stow
```sh
# Linux
stow -d stow -t ~ common linux

# macOS
stow -d stow -t ~ common mac

# Unstow a package
stow -d stow -t ~ -D linux
```

Notes:
- Ensure `~/.local/bin` is on `PATH` (the Linux `.bashrc` does this).
- Run stow from the repo root; add/swap packages as needed.

## One-shot install
```sh
git clone <repo-url> ~/my-dot-files
cd ~/my-dot-files
./install.sh
```
- macOS: ensures Stow is installed and stows `common` + `mac`.
- Debian/Ubuntu: installs prerequisites (stow/vim/pyenv deps, ctags, mingw, irssi, etc.), backs up existing dotfiles, stows `common` + `linux`, installs Vundle/plugins, and sets up GEF.
- Other Linux: stows `common` + `linux` (install extra build tools manually if needed).

## Helpful commands
- `make lint`: run `shellcheck` if available against key scripts.
- `make check`: syntax-check scripts with `bash -n`.
- `make stow-linux` / `make stow-mac`: dry-run Stow to detect conflicts.
- `make bootstrap-linux` / `make bootstrap-mac`: run the platform bootstrap scripts directly.
