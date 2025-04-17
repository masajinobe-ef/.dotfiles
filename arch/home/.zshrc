#!/bin/zsh

### Zsh Settings
export ZSH_THEME="robbyrussell"
export DISABLE_AUTO_TITLE="true"
setopt TRANSIENT_RPROMPT
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

### Prompt
autoload -Uz colors && colors

typeset -gA fg
fg[love]=$'\e[31m'        # red
fg[gold]=$'\e[33m'        # yellow
fg[iris]=$'\e[34m'        # blue
fg[foam]=$'\e[36m'        # cyan
fg[rose]=$'\e[35m'        # magenta
fg[pine]=$'\e[32m'        # green

autoload -Uz add-zsh-hook vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red} %f'
zstyle ':vcs_info:*' stagedstr '%F{yellow} %f'
zstyle ':vcs_info:*' formats '%F{blue} %b%f %u%c'
zstyle ':vcs_info:*' actionformats '%F{red} %b|%a%f %u%c'

+vi-git-repo-status() {
  if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    hook_com[branch]="%F{yellow}${hook_com[branch]}%f"
  fi
}
zstyle ':vcs_info:git*+set-message:*' hooks git-repo-status

add-newline-to-prompt() {
  if [[ -n "$_first_prompt" ]]; then
    print
  else
    _first_prompt=1
  fi
}


set_prompt() {
    DIR_PROMPT="%F{cyan}%(4~|%2~|%3~)%f"
    PROMPT="$DIR_PROMPT %(?.%F{green}❯%f.%F{red}❯%f) "
}

RPROMPT='${vcs_info_msg_0_} %(!.%F{red}⚡%f.%F{green} %f) %F{8}%D{%H:%M}%f'

add-zsh-hook precmd add-newline-to-prompt
add-zsh-hook precmd set_prompt
add-zsh-hook precmd vcs_info

### Oh My Zsh Framework
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
    ~/.dotfiles/personal/sh
    ~/.local/bin
    ~/.local/scripts
    ~/.local/share
    ~/.cargo/bin
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
