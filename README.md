# My Dot Files

Dotfiles for Linux and macOS managed with GNU Stow.

## Layout
- `install.sh`: detects OS and runs the platform bootstrap script.
- `scripts/bootstrap-linux.sh`: Debian/Ubuntu bootstrap (apt-based), plus stow and post-install setup.
- `scripts/bootstrap-mac.sh`: macOS bootstrap (Homebrew-based), plus stow.
- `scripts/_template.sh`: template for new scripts in `scripts/`.
- `stow/linux`: Linux shell/editor/git/tmux/ssh files and helper scripts in `.local/bin`.
- `stow/mac`: macOS zsh/tmux/git/GPG files.
- `stow/common`: optional shared package (currently not present in this repo).
- `Makefile`: shortcuts for lint/syntax checks, stow dry-run, and direct bootstrap runs.

## One-shot install
```sh
git clone <repo-url> ~/my-dot-files
cd ~/my-dot-files
./install.sh
```

Current behavior:
- macOS:
  - Requires Homebrew.
  - Ensures `stow` and Node.js/npm are installed.
  - Installs Claude Code (`claude`) and Codex (`codex`) via npm.
  - Stows `common` (if present) and `mac`.
- Linux:
  - Requires `apt-get` (Debian/Ubuntu path).
  - Installs base packages, pyenv + Python, Vim/tmux tooling, GEF, Nerd Font symbols.
  - Installs Claude Code (`claude`) and Codex (`codex`) via npm.
  - Stows `common` (if present) and `linux`.

## Using Stow manually
```sh
# Linux
stow -d stow -t ~ linux

# macOS
stow -d stow -t ~ mac

# If you add a shared package later
stow -d stow -t ~ common linux

# Unstow
stow -d stow -t ~ -D linux
```

Notes:
- Ensure `~/.local/bin` is on `PATH`.
- Bootstrap copies repo `.gitignore` to `~/.gitignore` and sets `git config --global core.excludesfile ~/.gitignore`.
- Linux bootstrap removes stale symlinks for managed paths before re-stowing.
- Linux bootstrap backs up conflicting dotfiles (for a fixed list such as `.bashrc`, `.vimrc`, `.tmux.conf`, etc.) into `~/.dotfiles-backup-<timestamp>`.

## Linux managed helper scripts
Files in `stow/linux/.local/bin/` are stowed as symlinks into `~/.local/bin/`:
- `deb-update.sh`
- `fedora-update.sh`
- `mount-shared-folders.sh`
- `muda-extensao.sh`
- `redimensiona.sh`
- `remove-old-kernel.sh`
- `restart-vm-tools.sh`
- `ubuntu_cleaner.sh`

Important:
- Existing regular files in `~/.local/bin` with the same names are not auto-backed up by bootstrap and can cause Stow conflicts.

## Helpful commands
- `make check`: syntax check for install/bootstrap scripts (`bash -n`).
- `make lint`: `shellcheck` for install/bootstrap scripts when available.
- `make stow-linux` / `make stow-mac`: dry-run stow conflict detection.
- `make bootstrap-linux` / `make bootstrap-mac`: run bootstrap scripts directly.
