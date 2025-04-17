#!/bin/zsh

# Zsh Settings
export ZSH_THEME="robbyrussell"
export DISABLE_AUTO_TITLE="true"
setopt TRANSIENT_RPROMPT
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

### Oh My Zsh Framework
# Core framework configuration
export ZSH="$HOME/.oh-my-zsh"
plugins=(
  git
  fzf
  tmux
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

### Key Bindings
bindkey -s '^e' "tmux-workflow\n"
bindkey -s '^f' "tmux-sessionizer\n"

### Environment Configuration
export SUDO_PROMPT="ENTER YOUR PASSWORD: "
export TERM=$ZSH_TMUX_TERM

# --- Application Preferences ---
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="thorium-browser"

# --- Development Tools ---
export UV_LINK_MODE=copy
export RUFF_CACHE_DIR="$HOME/.cache/ruff"
export COMPOSE_BAKE=true

# --- Paths Configuration ---
typeset -U PATH path

path=(
    ~/.dotfiles
    ~/.local/bin
    ~/.local/scripts
    ~/.local/share
    ~/.cargo/bin
    /usr/lib/jvm/default/bin
    $path
)

### Aliases
alias v="nvim"
alias zc="source ~/.zshrc"
alias mv="mv -v"
alias rm="rm -rfv"
alias cp="cp -vr"
alias mkdir="mkdir -p"
alias s="clear; eza --long --header --icons=always --all --level=1 --group-directories-first --no-time"
alias pwdcp="pwd|tr -d '\n'|xclip -selection clipboard"
alias untar="tar -xvvf"
alias zz="zip -r"
alias uz="unzip"
alias orph="yay -Rns \$(yay -Qdtq)"
alias mirror-update="sudo reflector --verbose \
  --protocol https \
  --age 72 \
  --sort rate \
  --latest 15 \
  --country Germany,Russia,Netherlands \
  --exclude '.*(lcarilla\.de|kumi\.systems|soulharsh007\.dev|unixpeople\.org).*' \
  --download-timeout 20 \
  --connection-timeout 10 \
  --save /etc/pacman.d/mirrorlist"

### Zoxide Initialization
eval "$(zoxide init zsh)"

### Yazi Initialization
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
