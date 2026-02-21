# Repository Guidelines

This repo centralizes personal dotfiles plus bootstrap/install scripts for Linux and macOS. Keep changes small, idempotent, and documented so machines can be reprovisioned safely.

## Project Structure & Module Organization
- `install.sh` auto-detects OS and dispatches to `scripts/bootstrap-linux.sh` or `scripts/bootstrap-mac.sh`.
- `scripts/bootstrap-linux.sh` is the Debian/Ubuntu bootstrap path (it exits if `apt-get` is unavailable).
- `scripts/bootstrap-mac.sh` is the macOS bootstrap path (expects Homebrew).
- `scripts/_template.sh` is the starter for adding new helper scripts under `scripts/`.
- `stow/linux` contains Linux dotfiles and managed helpers in `stow/linux/.local/bin/`.
- `stow/mac` contains macOS dotfiles (`.zshrc`, `.p10k.zsh`, `.tmux.conf`, `.gitconfig`, `.gnupg/*`).
- `stow/common` is optional. The bootstrap scripts attempt to stow `common`, but will skip it if the directory does not exist.
- `stow/linux/.ssh/config` is tracked; do not commit private keys or secrets.

## Build, Test, and Development Commands
- `make check`: runs `bash -n` for `install.sh` and `scripts/bootstrap-*.sh`.
- `make lint`: runs `shellcheck` for `install.sh` and `scripts/bootstrap-*.sh` when installed.
- `make stow-linux` / `make stow-mac`: dry-run Stow to catch conflicts before applying links.
- `make bootstrap-linux` / `make bootstrap-mac`: runs full platform bootstrap (package/network side effects).
- For edits under `stow/linux/.local/bin`, run direct checks such as `bash -n stow/linux/.local/bin/deb-update.sh` and `shellcheck stow/linux/.local/bin/remove-old-kernel.sh` when possible.
- Dotfile spot checks in a throwaway shell/session: `tmux source-file stow/linux/.tmux.conf`, `vim -u stow/linux/.vimrc +qall`, `source stow/linux/.bashrc`, `source stow/mac/.zshrc`.

## Coding Style & Naming Conventions
- New scripts should use `#!/usr/bin/env bash` and `set -euo pipefail` unless legacy compatibility requires otherwise.
- Use 2-space indentation, quote variables, and prefer readable pipelines over compact one-liners.
- Keep bootstrap/install steps non-interactive and idempotent: check for existing tools first and use `-y` where supported.
- Use clear `log "..."` messages for long-running steps so remote output is easy to scan.
- Preserve ordering/style in dotfiles to minimize diff noise.
- Legacy scripts under `stow/linux/.local/bin` mix `sh`/`bash` styles and may be interactive; keep behavior changes explicit and scoped.

## Testing Guidelines
- Validate bootstrap changes in disposable environments that match targets:
  - Linux: Debian/Ubuntu with `apt-get`.
  - macOS: Homebrew installed.
- If you touch npm installer flow, verify CLI availability (`claude --version`, `codex --version`) after bootstrap.
- For Stow path changes, verify dry-run first (`make stow-linux` or `make stow-mac`) before real install.
- For destructive helpers (for example `remove-old-kernel.sh` and `ubuntu_cleaner.sh`), prefer dry-run visibility first and avoid testing on irreplaceable hosts.
- If a change impacts both platforms, test both or clearly note what remains unverified.

## Commit & Pull Request Guidelines
- Keep commit titles short, capitalized, present tense (about 72 chars max).
- In PR descriptions, include:
  - What changed.
  - Why it changed.
  - Side effects/migration notes.
- Record validation commands and tested platforms.
- Avoid mixing broad refactors with behavioral changes unless tightly coupled.
