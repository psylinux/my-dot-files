#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="${ROOT_DIR}/stow"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

ensure_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  log "GNU Stow not found, attempting install via Homebrew..."
  if command -v brew >/dev/null 2>&1; then
    brew install stow || die "Failed to install stow via Homebrew."
  else
    die "Homebrew not found. Install Homebrew or stow manually."
  fi
}

stow_packages() {
  local packages=("$@")
  mkdir -p "$HOME/.local/bin"
  log "Stowing packages: ${packages[*]}"
  stow -d "$STOW_DIR" -t "$HOME" -R "${packages[@]}"

  if [ -f "${STOW_DIR}/common/.gitignore" ]; then
    cp "${STOW_DIR}/common/.gitignore" "${HOME}/.gitignore"
    git config --global core.excludesfile "${HOME}/.gitignore" || log "Warning: failed to set global git excludesfile"
  fi
}

main() {
  ensure_stow
  stow_packages common mac
  log "Done. Restart your shell to pick up any PATH changes."
}

main "$@"
