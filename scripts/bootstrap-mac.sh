#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="${ROOT_DIR}/stow"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

ensure_homebrew() {
  command -v brew >/dev/null 2>&1 || die "Homebrew not found. Install Homebrew first."
}

ensure_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  log "GNU Stow not found, attempting install via Homebrew..."
  brew install stow || die "Failed to install stow via Homebrew."
}

ensure_node() {
  if command -v npm >/dev/null 2>&1; then
    return
  fi

  log "npm not found, installing Node.js via Homebrew..."
  brew install node || die "Failed to install Node.js via Homebrew."
}

install_npm_cli() {
  local label="$1"
  local package_name="$2"
  local bin_name="$3"
  local version="unknown"

  if command -v "${bin_name}" >/dev/null 2>&1; then
    version="$("${bin_name}" --version 2>/dev/null | head -n 1 || true)"
    log "${label} already installed (${version})"
    return
  fi

  log "Installing ${label} via npm package ${package_name}"
  if npm install -g "${package_name}"; then
    :
  elif NPM_CONFIG_PREFIX="${HOME}/.local" npm install -g "${package_name}"; then
    if [ -x "${HOME}/.local/bin/${bin_name}" ]; then
      log "${label} installed to ${HOME}/.local/bin/${bin_name}"
    fi
  else
    log "Warning: failed to install ${label}"
    return
  fi

  if ! command -v "${bin_name}" >/dev/null 2>&1 && [ -x "${HOME}/.local/bin/${bin_name}" ]; then
    log "Warning: ${bin_name} is installed but not on PATH; add \$HOME/.local/bin to your shell PATH."
  fi
}

install_ai_coding_tools() {
  install_npm_cli "Claude Code" "@anthropic-ai/claude-code" "claude"
  install_npm_cli "Codex" "@openai/codex" "codex"
}

stow_packages() {
  local requested=("$@")
  local packages=()
  for pkg in "${requested[@]}"; do
    if [ -d "${STOW_DIR}/${pkg}" ]; then
      packages+=("$pkg")
    else
      log "Skipping missing stow package '${pkg}'"
    fi
  done

  if [ "${#packages[@]}" -eq 0 ]; then
    log "No stow packages to apply; skipping stow step."
    return
  fi

  mkdir -p "$HOME/.local/bin"
  log "Stowing packages: ${packages[*]}"
  stow -d "$STOW_DIR" -t "$HOME" -R "${packages[@]}"

  if [ -f "${ROOT_DIR}/.gitignore" ]; then
    cp "${ROOT_DIR}/.gitignore" "${HOME}/.gitignore"
    git config --global core.excludesfile "${HOME}/.gitignore" || log "Warning: failed to set global git excludesfile"
  fi
}

main() {
  ensure_homebrew
  ensure_stow
  ensure_node
  install_ai_coding_tools
  stow_packages common mac
  log "Done. Restart your shell to pick up any PATH changes."
}

main "$@"
