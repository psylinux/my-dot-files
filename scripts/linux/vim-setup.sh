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

# Dependencies (reference)
# - Vim with +python3: verify via `vim --version`.
# - Nerd Fonts for icons: e.g., clone https://github.com/ryanoasis/nerd-fonts.git and run install.
# - Vundle plugin manager (this script installs it).
# - LanguageTool CLI (optional): curl -L https://raw.githubusercontent.com/languagetool-org/languagetool/master/install.sh | sudo bash -b
# - Nerd fonts for NERDTree icons: brew tap homebrew/cask-fonts && brew install --cask font-hack-nerd-font (mac) or install via nerd-fonts repo.
# - pyenv Python (set via PYENV_VERSION, defaults 3.12.7).
# - ctags/universal-ctags, fzf, flake8, yarn (for markdown-preview.nvim).
#   yarn quick setup: asdf plugin-add yarn && asdf install yarn 1.22.4 && (cd ~/.vim/bundle/markdown-preview.nvim/app && asdf local yarn 1.22.4)

PYENV_VERSION="${PYENV_VERSION:-3.12.7}"
PYENV_ROOT="${HOME}/.pyenv"
OS_LC="$(uname -s | tr '[:upper:]' '[:lower:]')"

log() { printf '[vim-setup] %s\n' "$*"; }

die() { log "$*"; exit 1; }

detect_pkg_manager() {
  case "$OS_LC" in
    darwin*)
      if command -v brew >/dev/null 2>&1; then
        echo "brew"
      else
        echo ""
      fi
      ;;
    linux*)
      if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
      elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
      elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
      else
        echo ""
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

install_packages() {
  case "$1" in
    brew)
      brew install git curl pyenv vim ctags fzf flake8 || die "brew install failed"
      ;;
    apt)
      sudo apt-get update -y
      sudo apt-get install -y git curl build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils \
        tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3-pip \
        vim fzf flake8
      if apt-cache show universal-ctags >/dev/null 2>&1; then
        sudo apt-get install -y universal-ctags
      elif apt-cache show exuberant-ctags >/dev/null 2>&1; then
        sudo apt-get install -y exuberant-ctags
      else
        log "ctags package not found; skipping (install manually if needed)."
      fi
      ;;
    dnf)
      sudo dnf install -y git curl make gcc gcc-c++ zlib-devel bzip2 bzip2-devel \
        readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel \
        xz-devel python3-pip ctags fzf python3-flake8 vim-enhanced
      ;;
    pacman)
      sudo pacman -Sy --noconfirm git curl base-devel openssl zlib bzip2 \
        readline sqlite tk libffi xz python-pip ctags fzf python-flake8 vim
      ;;
    *)
      die "No supported package manager found. Install git, curl, build tools, python3-pip, ctags, and vim manually."
      ;;
  esac
}

ensure_pyenv() {
  if [ ! -d "$PYENV_ROOT" ]; then
    log "Installing pyenv into ${PYENV_ROOT}"
    if [[ "$OS_LC" == darwin* ]] && command -v brew >/dev/null 2>&1; then
      brew install pyenv
    else
      git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
    fi
  else
    log "pyenv already present at ${PYENV_ROOT}"
  fi

  export PYENV_ROOT
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  if ! command -v pyenv >/dev/null 2>&1; then
    die "pyenv not on PATH after install."
  fi

  # Initialize for current shell so installs work.
  eval "$(pyenv init -)"

  # Persist pyenv init to .bashrc if not already present.
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

ensure_python() {
  if ! pyenv versions --bare | grep -Fx "$PYENV_VERSION" >/dev/null 2>&1; then
    log "Installing Python ${PYENV_VERSION} via pyenv"
    pyenv install "$PYENV_VERSION"
  else
    log "Python ${PYENV_VERSION} already installed"
  fi

  pyenv global "$PYENV_VERSION"
  pyenv rehash
  pip3 install --upgrade pip
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

ensure_vim_python() {
  if vim --version | grep -q "+python3"; then
    log "Vim has +python3 support"
  else
    log "Warning: Vim lacks +python3 support; Python-related plugins may fail."
  fi
}

install_nerd_fonts() {
  local nf_dir="/opt/nerd-fonts"
  if [[ "$OS_LC" == darwin* ]] && command -v brew >/dev/null 2>&1; then
    brew tap homebrew/cask-fonts || true
    brew install --cask font-hack-nerd-font || log "Warning: Nerd Font cask install failed"
  else
    if [ -d "$nf_dir/.git" ]; then
      log "Nerd Fonts repo already present at ${nf_dir}"
    else
      log "Installing Nerd Fonts into ${nf_dir}"
      sudo git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git "$nf_dir"
    fi
    if [ -x "$nf_dir/install.sh" ]; then
      (cd "$nf_dir" && sudo ./install.sh)
    else
      log "Warning: Nerd Fonts install.sh not found at ${nf_dir}"
    fi
  fi
}

install_languagetool() {
  log "Installing LanguageTool CLI"
  curl -L https://raw.githubusercontent.com/languagetool-org/languagetool/master/install.sh | sudo bash -b
}

setup_markdown_preview_yarn() {
  local yarn_ver="1.22.4"
  local plugin_app="${HOME}/.vim/bundle/markdown-preview.nvim/app"
  if ! command -v asdf >/dev/null 2>&1; then
    log "asdf not found; skipping yarn setup for markdown-preview.nvim"
    return
  fi
  if [ ! -d "$plugin_app" ]; then
    log "markdown-preview.nvim app dir not found at ${plugin_app}; skipping yarn setup"
    return
  fi
  asdf plugin-add yarn >/dev/null 2>&1 || true
  asdf install yarn "$yarn_ver" >/dev/null 2>&1 || true
  (cd "$plugin_app" && asdf local yarn "$yarn_ver" && yarn install) || \
    log "Warning: yarn install for markdown-preview.nvim failed"
}

main() {
  pm="$(detect_pkg_manager)"
  if [ -z "$pm" ]; then
    die "Unsupported or undetected package manager/OS."
  fi
  install_packages "$pm"
  ensure_pyenv
  ensure_python
  ensure_vim_python
  install_nerd_fonts
  install_languagetool
  install_vundle
  setup_markdown_preview_yarn
  log "Done. Restart your shell to load pyenv changes."
}

main "$@"
