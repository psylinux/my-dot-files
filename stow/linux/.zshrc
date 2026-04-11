# ===== Exports and PATH (apply to all shells) =====
export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/sbin:/usr/local/sbin:$PATH"
export EDITOR="vim"

# ===== Oh My Zsh =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ===== PyEnv =====
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PYTHON_CONFIGURE_OPTS="--enable-shared"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  if pyenv commands | grep -Fqx virtualenv-init 2>/dev/null; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

# ===== History =====
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY

# ===== Aliases =====
alias ls='ls -lah --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias vi='vim'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias getclip="xclip -selection c -o"
alias setclip="xclip -selection c && xclip -selection c -o"
alias recshell='mkdir -p "$HOME/logs" && script -f "$HOME/logs/$(date +"%d-%b-%y_%H-%M-%S")_shell.log"'

# ===== SSH Agent =====
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null
fi

# ===== VMware shared folders =====
if command -v mount-shared-folders.sh >/dev/null 2>&1; then
  mount-shared-folders.sh
fi
