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

ensure_vim_tools() {
  # Apple's /usr/bin/vim is built without Python 3, which UltiSnips and
  # jedi-vim need. Homebrew's vim has it. fzf.vim needs the fzf binary,
  # and vimux/vim-tmux expect tmux (its config is stowed from stow/mac).
  local formula
  for formula in vim fzf tmux; do
    if brew list --formula "${formula}" >/dev/null 2>&1; then
      continue
    fi
    log "Installing ${formula} via Homebrew..."
    brew install "${formula}" || log "Warning: failed to install ${formula} via Homebrew."
  done
}

install_omz_addon() {
  local kind="$1"
  local name="$2"
  local url="$3"
  local zsh_dir="${ZSH:-${HOME}/.oh-my-zsh}"
  local custom_dir="${ZSH_CUSTOM:-${zsh_dir}/custom}"

  # Oh My Zsh looks in $ZSH_CUSTOM first, then $ZSH, so accept either.
  if [ -d "${custom_dir}/${kind}/${name}" ] || [ -d "${zsh_dir}/${kind}/${name}" ]; then
    log "${name} already installed"
    return
  fi

  log "Installing ${name} into ${custom_dir}/${kind}"
  git clone --quiet --depth=1 "${url}" "${custom_dir}/${kind}/${name}" || log "Warning: failed to clone ${name}"
}

ensure_oh_my_zsh() {
  # stow/mac/.zshrc loads Oh My Zsh with the powerlevel10k theme and two
  # third-party plugins; without them every new shell starts with errors.
  local zsh_dir="${ZSH:-${HOME}/.oh-my-zsh}"
  if [ -d "${zsh_dir}" ]; then
    log "Oh My Zsh already installed"
  else
    local installer
    log "Installing Oh My Zsh (unattended)"
    if ! installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
      log "Warning: failed to download the Oh My Zsh installer; skipping zsh theme and plugins"
      return
    fi
    # KEEP_ZSHRC: don't let the installer replace ~/.zshrc; stow manages it.
    if ! ZSH="${zsh_dir}" RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "${installer}" "" --unattended; then
      log "Warning: Oh My Zsh install failed; skipping zsh theme and plugins"
      return
    fi
  fi

  install_omz_addon themes powerlevel10k https://github.com/romkatv/powerlevel10k.git
  install_omz_addon plugins zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
  install_omz_addon plugins zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
}

resolve_path() {
  # Fully resolved path. Prints a path even for dangling links (exit 1).
  readlink -f "$1" 2>/dev/null || true
}

backup_conflicts() {
  # Move aside anything at a path the given stow packages manage that stow
  # would refuse to replace: regular files, and symlinks pointing anywhere
  # other than this repo's copy (stale links from an old checkout, links
  # owned by another tool). The path list comes from the packages themselves.
  local stamp backup_dir repo_real
  stamp="$(date +%Y%m%d%H%M%S)"
  backup_dir="${HOME}/.dotfiles-backup-${stamp}"
  repo_real="$(resolve_path "${ROOT_DIR}")"

  local any=0 pkg pkg_dir src rel target target_real
  for pkg in "$@"; do
    pkg_dir="${STOW_DIR}/${pkg}"
    [ -d "${pkg_dir}" ] || continue
    while IFS= read -r -d '' src; do
      rel="${src#"${pkg_dir}/"}"
      target="${HOME}/${rel}"
      if [ ! -e "${target}" ] && [ ! -L "${target}" ]; then
        continue
      fi
      # Already ours, directly or through a folded parent directory
      # (stow -R --no-folding turns a folded parent back into a real one).
      target_real="$(resolve_path "${target}")"
      if [ "${target_real}" = "$(resolve_path "${src}")" ]; then
        continue
      fi
      # A real file reached through a parent symlink into this repo: moving
      # it would move a repo file. Leave it for stow to report.
      if [ ! -L "${target}" ] && [[ "${target_real}" == "${repo_real}/"* ]]; then
        log "Warning: ~/${rel} resolves into this repo (${target_real}); not moving it"
        continue
      fi
      log "Backing up ~/${rel} to ${backup_dir}/${rel}"
      mkdir -p "${backup_dir}/$(dirname "${rel}")"
      mv "${target}" "${backup_dir}/${rel}"
      any=1
    done < <(find "${pkg_dir}" \( -type f -o -type l \) -print0)
  done

  if [ "${any}" -eq 1 ]; then
    log "Backups stored in ${backup_dir}"
  fi
}

install_vim_plugins() {
  local vundle_dir="${HOME}/.vim/bundle/Vundle.vim"
  if [ -d "${vundle_dir}/.git" ]; then
    log "Updating Vundle"
    git -C "${vundle_dir}" pull --quiet || log "Warning: failed to update Vundle"
  else
    log "Installing Vundle"
    if ! git clone --quiet https://github.com/VundleVim/Vundle.vim.git "${vundle_dir}"; then
      log "Warning: failed to clone Vundle; skipping Vim plugins"
      return
    fi
  fi

  local vim_bin
  vim_bin="$(brew --prefix)/bin/vim"
  [ -x "${vim_bin}" ] || vim_bin="vim"

  log "Installing Vim plugins via Vundle (this can take a few minutes)"
  "${vim_bin}" -i NONE +PluginInstall +qall || log "Warning: Vundle PluginInstall reported errors"
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
  # --no-folding: never symlink a whole directory (e.g. ~/.gnupg) into the
  # repo, or tools would write keys and runtime data into the work tree.
  stow -d "$STOW_DIR" -t "$HOME" -R --no-folding "${packages[@]}"

  # The global git ignore list is stowed to ~/.config/git/ignore, which git
  # reads with no config. Don't add `git config --global` calls: ~/.gitconfig
  # is a symlink into this repo, so git would rewrite the tracked file.
}

main() {
  ensure_homebrew
  ensure_stow
  ensure_node
  ensure_vim_tools
  ensure_oh_my_zsh
  install_ai_coding_tools
  backup_conflicts common mac
  stow_packages common mac
  install_vim_plugins
  log "Done. Restart your shell to pick up any PATH changes."
}

main "$@"
