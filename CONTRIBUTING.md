# Contributing

## Overview
- Dotfiles live in `stow/<platform>` and are applied via GNU Stow.
- `install.sh` chooses the platform bootstrap script (`scripts/bootstrap-linux.sh` or `scripts/bootstrap-mac.sh`).
- Bootstrap scripts attempt to stow `common` plus platform package; missing packages are skipped with a log message.
- Entry points: `install.sh` (auto-selects platform), `scripts/bootstrap-linux.sh`, `scripts/bootstrap-mac.sh`.
- Helper scripts sit in `scripts/`; use `scripts/_template.sh` when adding new ones.

## Quickstart
- Clone and run `./install.sh` to set up your machine.
- Before opening a PR, run `make check` and `make lint` to catch syntax/lint issues.
- Use dry-run Stow to spot conflicts: `make stow-linux` or `make stow-mac`.

## Adding packages or installers
- Linux: `scripts/bootstrap-linux.sh` is Debian/Ubuntu-oriented and exits if `apt-get` is not present. Add packages in `install_packages_apt` or add dedicated helpers when extra setup is required.
- macOS: keep bootstrap minimal; prefer Homebrew installs in focused helpers (`ensure_*`/`install_*` style).
- AI coding CLIs are installed via npm helpers (`install_ai_coding_tools` / `install_npm_cli`) on both Linux and macOS.
- Keep installers idempotent: check for presence, use `-y` flags, and avoid prompts.
- Log clearly with `log "message"` so automation output is easy to skim.

## Editing dotfiles
- Keep changes small and mirror existing ordering to reduce noisy diffs.
- If you add new stow packages, keep platform-specific files under `stow/linux` or `stow/mac`; add `stow/common` only when shared files are truly cross-platform.
- For shell init changes, avoid introducing interactive prompts; prefer environment variables or documented flags.
- Linux helper scripts in `stow/linux/.local/bin` are managed by Stow and become symlinks in `~/.local/bin`.

## Style
- Scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use 2-space indentation, quote variables, and prefer readable pipelines over dense one-liners.
- Add brief comments only when behavior is non-obvious (e.g., required env vars, special paths).
- Some legacy helper scripts in `stow/linux/.local/bin` use `#!/bin/sh`; preserve style unless you intentionally migrate them.

## Testing & validation
- Minimum: `bash -n` on modified scripts and `shellcheck` when available (`make check` + `make lint` for install/bootstrap scripts).
- If you modify files under `stow/linux/.local/bin`, run direct checks on those files (they are not included in `make lint` today).
- Stow dry-run (`make stow-linux` / `make stow-mac`) to ensure no conflicts.
- Spot-check dotfile loadability in a throwaway shell/tmux session after changes.
- If you touch pyenv init, confirm shells still start cleanly without `pyenv virtualenv` installed.
- For potentially destructive cleanup scripts (`remove-old-kernel.sh`, `ubuntu_cleaner.sh`), validate in disposable environments first.
