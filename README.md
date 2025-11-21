# My Dot Files

Dotfiles for Linux and macOS managed with GNU Stow.

## Layout
- `stow/common`: shared settings (global `.gitignore`).
- `stow/linux`: Linux shell/editor/git/tmux configs plus helper scripts in `.local/bin`.
- `stow/mac`: macOS zsh/tmux/git configs and GPG agent files.
- `scripts/linux`: one-off setup helpers (`deb-setup.sh`, `vim-setup.zsh`) run manually.

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
