# My Dot Files

Dotfiles for Linux and macOS managed with GNU Stow.

## Layout
- `stow/common`: shared settings (currently empty placeholder for cross-platform files).
- `stow/linux`: Linux shell/editor/git/tmux configs, `.ssh/config`, plus helper scripts in `.local/bin`.
- `stow/mac`: macOS zsh/tmux/git configs and GPG agent files.
- `scripts/linux`: one-off setup helpers (none currently).
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
- Linux shell startup will initialize `pyenv` when present and only run `pyenv virtualenv-init` if the plugin is installed.
- Shell sessions are recorded to `~/logs/<date>_shell.log`; remove that block in `stow/linux/.bashrc` if you prefer not to log.
- Global gitignore: bootstrap copies the repo root `.gitignore` to `~/.gitignore` and sets `core.excludesfile`.

## One-shot install
```sh
git clone <repo-url> ~/my-dot-files
cd ~/my-dot-files
./install.sh
```
- macOS: ensures Stow is installed and stows `common` + `mac`.
- Debian/Ubuntu: installs prerequisites (stow/vim/pyenv deps, ctags, mingw, irssi, etc.), backs up existing dotfiles, stows `common` + `linux`, installs Vundle/plugins, and sets up GEF.
- Other Linux: stows `common` + `linux` (install extra build tools manually if needed).

### What the Linux bootstrap installs
- Core tools: git, curl, stow, tmux, vim, irssi/bitlbee, build-essential toolchain, ctags, MinGW cross-compilers.
- Vim helpers: fzf (>= ${FZF_MIN_VERSION:-0.56.0} ensured via binary download if needed), ripgrep, silversearcher-ag, python3 toolchain, nodejs/npm/yarn (for markdown-preview; falls back to npm if yarn fails), and Python packages `pynvim` + `jedi`.
- Fonts: Nerd Font symbols (downloaded from nerd-fonts releases) plus fontconfig cache refresh for proper Airline/devicons glyphs.
- pyenv with Python `${PYENV_VERSION}` for plugin support.
- Vundle plugins, tmux plugins, and optional cron for log rotation.
- If `markdown-preview.nvim` is present, bootstrap installs its JS deps (prefers `asdf`/yarn when available, falls back to npm).

## Helpful commands
- `make lint`: run `shellcheck` if available against key scripts.
- `make check`: syntax-check scripts with `bash -n`.
- `make stow-linux` / `make stow-mac`: dry-run Stow to detect conflicts.
- `make bootstrap-linux` / `make bootstrap-mac`: run the platform bootstrap scripts directly.
