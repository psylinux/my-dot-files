# My Dot Files

Dotfiles for Linux and macOS managed with GNU Stow.

## Layout
- `install.sh`: detects OS and runs the platform bootstrap script.
- `scripts/bootstrap-linux.sh`: Debian/Ubuntu bootstrap (apt-based), plus stow and post-install setup.
- `scripts/bootstrap-mac.sh`: macOS bootstrap (Homebrew-based), plus stow and Vim plugin setup.
- `scripts/_template.sh`: template for new scripts in `scripts/`.
- `stow/linux`: Linux shell/git/tmux/ssh files and helper scripts in `.local/bin`.
- `stow/mac`: macOS zsh/tmux/git/GPG files.
- `stow/common`: files shared by both platforms (`.vimrc` and the global git ignore list at `.config/git/ignore`).
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
  - Installs Homebrew `vim` (Apple's vim lacks Python 3), `fzf`, and `tmux`.
  - Installs Oh My Zsh, the powerlevel10k theme, and the `zsh-autosuggestions` / `zsh-syntax-highlighting` plugins that `stow/mac/.zshrc` loads (skipped when already present in `$ZSH` or `$ZSH_CUSTOM`).
  - Installs Claude Code (`claude`) and Codex (`codex`) via npm.
  - Backs up conflicting dotfiles, stows `common` and `mac`, then installs Vundle and runs `:PluginInstall`.
- Linux:
  - Requires `apt-get` (Debian/Ubuntu path).
  - Installs base packages, pyenv + Python, Vim/tmux tooling, GEF, Nerd Font symbols.
  - Installs Claude Code (`claude`) and Codex (`codex`) via npm.
  - Stows `common` (if present) and `linux`.

## Using Stow manually
```sh
# Always pass --no-folding so directories such as ~/.ssh and ~/.gnupg stay
# real directories instead of symlinks into this repo.

# Linux
stow -d stow -t ~ --no-folding linux

# macOS
stow -d stow -t ~ --no-folding mac

# Include the shared package (e.g. .vimrc)
stow -d stow -t ~ --no-folding common linux
stow -d stow -t ~ --no-folding common mac

# Unstow
stow -d stow -t ~ -D linux
```

Notes:
- Ensure `~/.local/bin` is on `PATH`.
- The global git ignore list is stowed to `~/.config/git/ignore`, git's default location, so no `core.excludesfile` is set. The repo's own `.gitignore` only covers this repo.
- Avoid `git config --global` writes: `~/.gitconfig` is a symlink into this repo, so they edit the tracked file.
- Linux bootstrap removes stale symlinks for managed paths before re-stowing.
- Both bootstraps back up anything that would block stow into `~/.dotfiles-backup-<timestamp>`: regular files, or symlinks pointing somewhere other than this repo, at any path the stowed packages manage. The list is built from the package contents, so new dotfiles are covered automatically.

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
- Existing regular files in `~/.local/bin` with the same names are backed up by bootstrap before stowing.

## Helpful commands
- `make check`: syntax check for install/bootstrap scripts (`bash -n`).
- `make lint`: `shellcheck` for install/bootstrap scripts when available.
- `make stow-linux` / `make stow-mac`: dry-run stow conflict detection (auto-includes `common` when `stow/common` exists).
- `make bootstrap-linux` / `make bootstrap-mac`: run bootstrap scripts directly.
