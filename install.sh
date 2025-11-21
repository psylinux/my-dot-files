#!/usr/bin/env bash
set -euo pipefail

# Copyright 2020 Marcos Azevedo (aka pylinux) : psylinux[at]gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_LC="$(uname -s | tr '[:upper:]' '[:lower:]')"
PYENV_VERSION="${PYENV_VERSION:-3.12.7}"
PYENV_ROOT="${HOME}/.pyenv"
PYENV_PIP=""

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

ensure_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  log "GNU Stow not found, attempting install..."
  if [[ "$OS_LC" == darwin* ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install stow || die "Failed to install stow via Homebrew."
    else
      die "Homebrew not found. Install Homebrew or stow manually."
    fi
  else
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y stow || die "Failed to install stow via apt-get."
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y stow || die "Failed to install stow via dnf."
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman --noconfirm -S stow || die "Failed to install stow via pacman."
    else
      die "Package manager not detected. Install stow manually."
    fi
  fi
}

stow_packages() {
  local packages=("$@")
  mkdir -p "$HOME/.local/bin"
  log "Stowing packages: ${packages[*]}"
  stow -d "$SCRIPT_DIR/stow" -t "$HOME" -R "${packages[@]}"

  # Ensure global git ignore is in place.
  if [ -f "$SCRIPT_DIR/stow/common/.gitignore" ]; then
    cp "$SCRIPT_DIR/stow/common/.gitignore" "$HOME/.gitignore"
    git config --global core.excludesfile "$HOME/.gitignore" || log "Warning: failed to set global git excludesfile"
  fi
}

backup_conflicts() {
  local backup_dir="${HOME}/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
  local paths=(
    ".bashrc"
    ".gitconfig"
    ".gitignore"
    ".tmux.conf"
    ".vimrc"
    ".vim"
    ".irssi"
    ".git-prompt.sh"
  )

  local any=0
  for p in "${paths[@]}"; do
    local target="${HOME}/${p}"
    if [ -L "$target" ]; then
      log "Removing existing symlink ${p}"
      rm -f "$target"
      any=1
    elif [ -e "$target" ]; then
      log "Backing up ${p} to ${backup_dir}/${p}"
      mkdir -p "${backup_dir}/$(dirname "$p")"
      mv "$target" "${backup_dir}/${p}"
      any=1
    fi
  done

  if [ "$any" -eq 1 ]; then
    log "Backups stored in ${backup_dir}"
  fi
}

install_packages_apt() {
  log "Updating package lists"
  sudo apt-get update -y

  log "Installing base packages"
  sudo apt-get install -y \
    git curl ca-certificates build-essential pkg-config \
    stow tmux vim irssi bitlbee bitlbee-plugin-otr libnotify-bin \
    python3 python3-pip python3-venv python3-dev \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev
}

install_ctags_apt() {
  if apt-cache show universal-ctags >/dev/null 2>&1; then
    sudo apt-get install -y universal-ctags
  elif apt-cache show exuberant-ctags >/dev/null 2>&1; then
    sudo apt-get install -y exuberant-ctags
  else
    log "ctags package not found; skipping (install manually if needed)."
  fi
}

install_mingw_apt() {
  log "Installing MinGW cross-compilers"
  sudo apt-get install -y mingw-w64 gcc-mingw-w64 g++-mingw-w64 binutils-mingw-w64 clang llvm
}

ensure_pyenv() {
  if [ ! -d "$PYENV_ROOT" ]; then
    log "Installing pyenv to ${PYENV_ROOT}"
    git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
  else
    log "pyenv already present at ${PYENV_ROOT}"
  fi

  export PYENV_ROOT
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  command -v pyenv >/dev/null 2>&1 || die "pyenv not on PATH after install."
  eval "$(pyenv init -)"

  if ! pyenv versions --bare | grep -Fx "$PYENV_VERSION" >/dev/null 2>&1; then
    log "Installing Python ${PYENV_VERSION} via pyenv"
    pyenv install "$PYENV_VERSION"
  else
    log "Python ${PYENV_VERSION} already installed in pyenv"
  fi

  pyenv global "$PYENV_VERSION"
  pyenv rehash
  PYENV_PIP="$(pyenv which pip)"
  "$PYENV_PIP" install --upgrade pip

  if ! grep -Fq 'pyenv init' "${HOME}/.bashrc"; then
    log "Appending pyenv init block to ~/.bashrc"
    cat >> "${HOME}/.bashrc" <<'EOF'
# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF
  fi
}

install_vundle() {
  local vundle_dir="${HOME}/.vim/bundle/Vundle.vim"
  if [ -d "$vundle_dir/.git" ]; then
    log "Updating Vundle"
    git -C "$vundle_dir" pull --quiet
  else
    log "Installing Vundle"
    git clone https://github.com/VundleVim/Vundle.vim.git "$vundle_dir"
  fi

  log "Installing Vim plugins via Vundle"
  vim +PluginInstall +qall
}

install_gef() {
  log "Installing GEF for GDB"
  sudo rm -rf /opt/gef
  sudo git clone https://github.com/hugsy/gef.git /opt/gef
  if [ -z "$PYENV_PIP" ]; then
    die "pyenv pip not detected; ensure_pyenv did not run?"
  fi
  "$PYENV_PIP" install --upgrade keystone-engine unicorn ropper capstone

  # Also install deps using the Python gdb is linked against (avoids missing modules at runtime).
  local gdb_py
  gdb_py="$(gdb -q -nx -ex "python import sys; print(sys.executable)" -ex quit 2>/dev/null | tail -n 1 || true)"
  if [ -z "$gdb_py" ] || [ ! -x "$gdb_py" ]; then
    log "Could not detect gdb's Python; falling back to python3 for GEF deps."
    gdb_py="$(command -v python3 || true)"
  fi
  if [ -n "$gdb_py" ] && [ -x "$gdb_py" ]; then
    "$gdb_py" -m pip install --break-system-packages --user --upgrade keystone-engine unicorn ropper capstone rpyc requests pygments retdec-python filebytes || \
      log "Warning: installing GEF deps for gdb python failed; check pip/PEP668 output."
  else
    log "Warning: no Python interpreter found for gdb; GEF extras may miss deps."
  fi

  # Write user .gdbinit to source GEF and prepend pyenv site-packages so gdb sees deps.
  local pyenv_site="${PYENV_ROOT}/versions/${PYENV_VERSION}/lib/python${PYENV_VERSION%.*}/site-packages"
  cat > "${HOME}/.gdbinit" <<EOF
python
import sys, os
site_dir = os.path.expanduser("${pyenv_site}")
if os.path.isdir(site_dir) and site_dir not in sys.path:
    sys.path.insert(0, site_dir)
end
source /opt/gef/gef.py
EOF

  # Install GEF extras for the current user (not root).
  if [ -d "${HOME}/.gef-extras" ]; then
    rm -rf "${HOME}/.gef-extras"
  fi
  /opt/gef/scripts/gef-extras.sh || log "Warning: gef-extras install hit an error."
}

install_vim_tools_apt() {
  log "Installing VIM tools (vim-python-jedi)"
  sudo apt-get install -y vim-python-jedi || log "vim-python-jedi not available; skipping."
}

run_debian_flow() {
  install_packages_apt
  install_ctags_apt
  install_mingw_apt
  ensure_pyenv
  backup_conflicts
  stow_packages common linux
  install_vundle
  install_gef
  install_vim_tools_apt
}

main() {
  case "$OS_LC" in
    darwin*)
      ensure_stow
      stow_packages common mac
      ;;
    linux*)
      if command -v apt-get >/dev/null 2>&1; then
        run_debian_flow
      else
        ensure_stow
        stow_packages common linux
        log "Note: non-apt Linux detected; install build/tools manually if needed."
      fi
      ;;
    *)
      die "Unsupported OS: $OS_LC"
      ;;
  esac

  log "Done. Restart your shell to pick up any PATH changes."
}

main "$@"
