#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="${ROOT_DIR}/stow"
PYENV_VERSION="${PYENV_VERSION:-3.12.7}"
PYENV_ROOT="${HOME}/.pyenv"
PYENV_PIP=""
NERD_FONTS_VERSION="${NERD_FONTS_VERSION:-3.2.1}"
FZF_MIN_VERSION="${FZF_MIN_VERSION:-0.56.0}"
LANGUAGETOOL_VERSION="${LANGUAGETOOL_VERSION:-5.9}"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

apt_update() {
  log "Updating apt cache"
  sudo apt-get update -y
}

ensure_stow() {
  if command -v stow >/dev/null 2>&1; then
    return
  fi

  log "GNU Stow not found, attempting install..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y stow || die "Failed to install stow via apt-get."
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y stow || die "Failed to install stow via dnf."
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman --noconfirm -S stow || die "Failed to install stow via pacman."
  else
    die "Package manager not detected. Install stow manually."
  fi
}

install_packages_apt() {
  local packages_common=(
    git curl ca-certificates build-essential pkg-config
    stow tmux vim irssi bitlbee bitlbee-plugin-otr libnotify-bin
    python3 python3-pip python3-venv python3-dev
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
    libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev
    fzf ripgrep silversearcher-ag default-jre-headless nodejs npm
    unzip fontconfig
  )
  local optional_packages=(languagetool)

  for pkg in "${optional_packages[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      packages_common+=("$pkg")
    else
      log "Optional package '$pkg' not available in apt; skipping."
    fi
  done

  log "Installing base packages (${#packages_common[@]})"
  sudo apt-get install -y "${packages_common[@]}"
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
  local mingw_packages=(mingw-w64 gcc-mingw-w64 g++-mingw-w64 binutils-mingw-w64 clang llvm)
  log "Installing MinGW cross-compilers (${#mingw_packages[@]})"
  sudo apt-get install -y "${mingw_packages[@]}"
}

ensure_pyenv() {
  # Remove broken ~/.bashrc symlink before touching it later.
  if [ -L "${HOME}/.bashrc" ] && [ ! -e "${HOME}/.bashrc" ]; then
    log "Removing broken ~/.bashrc symlink"
    rm -f "${HOME}/.bashrc"
  fi

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

  if ! grep -Fq 'pyenv init' "${HOME}/.bashrc" 2>/dev/null; then
    log "Appending pyenv init block to ~/.bashrc"
    mkdir -p "$(dirname "${HOME}/.bashrc")"
    touch "${HOME}/.bashrc"
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

setup_markdown_preview_yarn() {
  local plugin_app="${HOME}/.vim/bundle/markdown-preview.nvim/app"
  local yarn_ver="${MP_YARN_VERSION:-1.22.4}"

  if [ ! -d "${plugin_app}" ]; then
    log "Skipping markdown-preview.nvim yarn setup (plugin app dir missing)"
    return
  fi
  if ! command -v asdf >/dev/null 2>&1; then
    log "Skipping markdown-preview.nvim yarn setup (asdf not installed)"
    return
  fi

  asdf plugin-add yarn >/dev/null 2>&1 || true
  asdf install yarn "${yarn_ver}" >/dev/null 2>&1 || true
  (cd "${plugin_app}" && asdf local yarn "${yarn_ver}" && yarn install) || \
    log "Warning: yarn install for markdown-preview.nvim failed"
}

install_markdown_preview_deps() {
  local plugin_app="${HOME}/.vim/bundle/markdown-preview.nvim/app"
  local bin="${plugin_app}/node_modules/.bin/markdown-preview"

  if [ ! -d "${plugin_app}" ]; then
    log "Skipping markdown-preview.nvim deps (plugin app dir missing)"
    return
  fi
  if [ -x "${bin}" ]; then
    log "markdown-preview.nvim deps already installed"
    return
  fi

  if command -v yarn >/dev/null 2>&1; then
    log "Installing markdown-preview.nvim deps with yarn"
    (cd "${plugin_app}" && yarn install) || log "Warning: yarn install for markdown-preview.nvim failed"
  elif command -v npm >/dev/null 2>&1; then
    log "Installing markdown-preview.nvim deps with npm"
    (cd "${plugin_app}" && npm install) || log "Warning: npm install for markdown-preview.nvim failed"
  else
    log "Warning: npm/yarn not available; markdown-preview.nvim may not work until deps are installed"
  fi
}

ensure_languagetool() {
  local jar_paths=(
    "/opt/languagetool/languagetool.jar"
    "/opt/languagetool/LanguageTool-${LANGUAGETOOL_VERSION}/languagetool.jar"
    "/usr/share/languagetool/LanguageTool.jar"
    "/usr/share/java/languagetool.jar"
    "/usr/share/java/languagetool-standalone.jar"
  )

  for j in "${jar_paths[@]}"; do
    if [ -f "$j" ]; then
      # Verify jar supports --api (needed by Vim plugin). If not, force reinstall.
      if java -jar "$j" --help 2>&1 | grep -q -- '--api'; then
        log "LanguageTool detected at ${j}"
        return
      else
        log "LanguageTool jar at ${j} missing --api; reinstalling"
        sudo rm -rf /opt/languagetool
        break
      fi
    fi
  done

  if apt-cache show languagetool >/dev/null 2>&1; then
    log "Installing LanguageTool via apt"
    if sudo apt-get install -y languagetool; then
      return
    else
      log "Warning: apt install of LanguageTool failed, will try manual download."
    fi
  fi

  local url="https://languagetool.org/download/LanguageTool-${LANGUAGETOOL_VERSION}.zip"
  local tmp
  tmp="$(mktemp)"
  log "Downloading LanguageTool ${LANGUAGETOOL_VERSION} from ${url}"
  if ! curl -fsSL "${url}" -o "${tmp}"; then
    log "Warning: failed to download LanguageTool from ${url}"
    rm -f "${tmp}"
    return
  fi

  sudo mkdir -p /opt/languagetool
  if sudo unzip -oq "${tmp}" -d /opt/languagetool; then
    local jar
    jar="$(find /opt/languagetool -maxdepth 3 -name 'languagetool.jar' | head -n1 || true)"
    if [ -n "$jar" ] && [ -f "$jar" ]; then
      sudo ln -sf "$jar" /opt/languagetool/languagetool.jar
      log "LanguageTool installed to /opt/languagetool (jar: $jar)"
    else
      log "Warning: downloaded LanguageTool but could not find jar"
    fi
  else
    log "Warning: failed to unzip LanguageTool archive"
  fi
  rm -f "${tmp}"
}

install_gef() {
  log "Installing GEF for GDB"
  sudo rm -rf /opt/gef
  sudo git clone https://github.com/hugsy/gef.git /opt/gef
  if [ -z "$PYENV_PIP" ]; then
    die "pyenv pip not detected; ensure_pyenv did not run?"
  fi
  "$PYENV_PIP" install --upgrade keystone-engine unicorn ropper capstone

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

  if [ -d "${HOME}/.gef-extras" ]; then
    rm -rf "${HOME}/.gef-extras"
  fi
  /opt/gef/scripts/gef-extras.sh || log "Warning: gef-extras install hit an error."
}

install_vim_tools_apt() {
  log "Installing VIM tools (vim-python-jedi)"
  sudo apt-get install -y vim-python-jedi || log "vim-python-jedi not available; skipping."
}

install_node_tools() {
  if command -v yarn >/dev/null 2>&1; then
    log "yarn already installed"
    return
  fi

  if command -v npm >/dev/null 2>&1; then
    log "Installing yarn via npm (global)"
    sudo npm install -g yarn || log "Warning: failed to install yarn globally via npm"
  else
    log "npm not available; skipping yarn install"
  fi
}

install_python_vim_deps() {
  local pip_cmd="${PYENV_PIP:-$(command -v pip3 || true)}"
  if [ -z "$pip_cmd" ]; then
    log "pip not found; skipping Python vim deps"
    return
  fi

  log "Installing Python packages for Vim (pynvim, jedi)"
  "$pip_cmd" install --upgrade --user pynvim jedi || log "Warning: failed to install pynvim/jedi"
}

ensure_fzf_version() {
  local fzf_bin="${HOME}/.local/bin/fzf"
  local current_version=""

  if command -v fzf >/dev/null 2>&1; then
    current_version="$(fzf --version 2>/dev/null | awk '{print $1}')"
  fi

  if [ -n "$current_version" ] && [ "$(printf '%s\n%s\n' "$FZF_MIN_VERSION" "$current_version" | sort -V | tail -n1)" = "$current_version" ]; then
    log "fzf ${current_version} already meets requirement (>= ${FZF_MIN_VERSION})"
    return
  fi

  mkdir -p "${HOME}/.local/bin"
  local archive="fzf-${FZF_MIN_VERSION}-linux_amd64.tar.gz"
  local url="https://github.com/junegunn/fzf/releases/download/${FZF_MIN_VERSION}/${archive}"
  local tmp
  tmp="$(mktemp)"

  log "Installing fzf ${FZF_MIN_VERSION} to ${fzf_bin}"
  if ! curl -fsSL "${url}" -o "${tmp}"; then
    log "Warning: failed to download fzf ${FZF_MIN_VERSION} from ${url}"
    rm -f "${tmp}"
    return
  fi

  tar -C "$(dirname "${fzf_bin}")" -xzf "${tmp}" fzf || log "Warning: failed to extract fzf archive"
  rm -f "${tmp}"
}

install_tmux_plugins() {
  log "Installing tmux plugins (tpm and vim-tmux-focus-events)"
  mkdir -p "${HOME}/.tmux/plugins"
  if [ ! -d "${HOME}/.tmux/plugins/tpm/.git" ]; then
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  else
    git -C "${HOME}/.tmux/plugins/tpm" pull --quiet
  fi
  if [ ! -d "${HOME}/.tmux/plugins/vim-tmux-focus-events/.git" ]; then
    git clone https://github.com/tmux-plugins/vim-tmux-focus-events "${HOME}/.tmux/plugins/vim-tmux-focus-events"
  else
    git -C "${HOME}/.tmux/plugins/vim-tmux-focus-events" pull --quiet
  fi
  log "Reload tmux (prefix + r) and press prefix + I inside tmux to fetch plugins."
}

install_nerd_font_symbols() {
  local font_dir="${HOME}/.local/share/fonts/nerd-fonts-symbols"
  local font_file="${font_dir}/NerdFontsSymbolsOnly-Regular.ttf"
  if [ -f "${font_file}" ]; then
    log "Nerd Font symbols already present"
    return
  fi

  mkdir -p "${font_dir}"
  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/NerdFontsSymbolsOnly.zip"
  local tmp_zip
  tmp_zip="$(mktemp)"

  log "Downloading Nerd Font symbols (v${NERD_FONTS_VERSION})"
  if ! curl -fsSL "${zip_url}" -o "${tmp_zip}"; then
    log "Warning: failed to download Nerd Font symbols from ${zip_url}"
    rm -f "${tmp_zip}"
    return
  fi

  log "Installing Nerd Font symbols to ${font_dir}"
  unzip -oq "${tmp_zip}" -d "${font_dir}"
  rm -f "${tmp_zip}"
  fc-cache -f "${font_dir}" || log "Warning: fc-cache failed; fonts may require relogin"
}

ensure_logs_cron() {
  local cron_cmd_archive="find ${HOME}/logs -maxdepth 1 -type f -name '*.log' -mtime +30 -print0 | tar -czf ${HOME}/logs/archive-last-30days.tar.gz --null -T -"
  local cron_line_archive="0 11 * * * ${cron_cmd_archive}"

  local cron_cmd_delete="find ${HOME}/logs -maxdepth 1 -type f -name '*.log' -mtime +30 -delete"
  local cron_line_delete="10 11 * * * ${cron_cmd_delete}"

  local tmp_cron
  tmp_cron="$(mktemp)"
  crontab -l 2>/dev/null > "${tmp_cron}" || true

  local updated=false

  if ! grep -Fq "${cron_line_archive}" "${tmp_cron}"; then
    printf '%s\n' "${cron_line_archive}" >> "${tmp_cron}"
    updated=true
  fi

  if ! grep -Fq "${cron_line_delete}" "${tmp_cron}"; then
    printf '%s\n' "${cron_line_delete}" >> "${tmp_cron}"
    updated=true
  fi

  if [ "${updated}" = true ]; then
    crontab "${tmp_cron}"
    log "Installed cron to archive and delete ~/logs files older than 30 days (archive at 11:00, delete at 11:10)."
  else
    log "Cron for archiving and deleting ~/logs already present."
  fi

  rm -f "${tmp_cron}"
}

backup_conflicts() {
  local backup_dir="${HOME}/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
  local paths=(
    ".bashrc"
    ".gitconfig"
    ".gitignore"
    ".ssh/config"
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

remove_stale_symlinks() {
  local paths=(
    ".bashrc"
    ".gitconfig"
    ".gitignore"
    ".ssh/config"
    ".tmux.conf"
    ".vimrc"
    ".vim"
    ".irssi"
    ".git-prompt.sh"
  )

  # Add managed scripts under .local/bin
  while IFS= read -r fname; do
    paths+=(".local/bin/${fname}")
  done < <(find "${STOW_DIR}/linux/.local/bin" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null)

  for p in "${paths[@]}"; do
    local target="${HOME}/${p}"
    if [ -L "$target" ]; then
      local resolved
      resolved="$(readlink -f "$target" 2>/dev/null || readlink "$target")"
      if [[ "$resolved" != "${STOW_DIR}/"* ]]; then
        log "Removing stale symlink ${p} -> ${resolved}"
        rm -f "$target"
      fi
    fi
  done
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
  if ! command -v apt-get >/dev/null 2>&1; then
    die "apt-get not found. This bootstrap script targets Debian/Ubuntu."
  fi

  ensure_stow
  remove_stale_symlinks
  apt_update
  install_packages_apt
  install_ctags_apt
  install_mingw_apt
  ensure_pyenv
  install_node_tools
  install_python_vim_deps
  ensure_languagetool
  ensure_fzf_version
  remove_stale_symlinks
  backup_conflicts
  stow_packages common linux
  install_vundle
  setup_markdown_preview_yarn
  install_markdown_preview_deps
  install_gef
  install_vim_tools_apt
  install_tmux_plugins
  install_nerd_font_symbols
  ensure_logs_cron
  log "Done. Restart your shell to pick up any PATH changes."
}

main "$@"
