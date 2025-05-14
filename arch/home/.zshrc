# ------------------------------------------------------------------------------
# ZSH CORE SETTINGS
# ------------------------------------------------------------------------------
export ZSH_THEME="robbyrussell"
export DISABLE_AUTO_TITLE="true"
setopt TRANSIENT_RPROMPT

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# ------------------------------------------------------------------------------
# PROMPT CONFIGURATION
# ------------------------------------------------------------------------------
autoload -Uz colors && colors
typeset -gA fg
fg[love]=$'\e[31m'        # red
fg[gold]=$'\e[33m'        # yellow
fg[iris]=$'\e[34m'        # blue
fg[foam]=$'\e[36m'        # cyan
fg[rose]=$'\e[35m'        # magenta
fg[pine]=$'\e[32m'        # green

# VCS info setup
autoload -Uz add-zsh-hook vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red} %f'
zstyle ':vcs_info:*' stagedstr '%F{yellow} %f'
zstyle ':vcs_info:*' formats '%F{blue} %b%f %u%c'
zstyle ':vcs_info:*' actionformats '%F{red} %b|%a%f %u%c'

+vi-git-repo-status() {
  [[ $(git status --porcelain | wc -l) -gt 0 ]] && hook_com[branch]="%F{yellow}${hook_com[branch]}%f"
}

# Prompt hooks
add-zsh-hook precmd vcs_info
add-zsh-hook precmd set_prompt

set_prompt() {
    DIR_PROMPT="%F{cyan}%(4~|%2~|%3~)%f"
    PROMPT="$DIR_PROMPT %(?.%F{green}❯%f.%F{red}❯%f) "
    RPROMPT='${vcs_info_msg_0_} %(!.%F{red}⚡%f.%F{green} %f) %F{8}%D{%H:%M}%f'
}

# ------------------------------------------------------------------------------
# OH-MY-ZSH CONFIGURATION
# ------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
plugins=(git fzf tmux zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# CUSTOM WIDGETS & KEYBINDINGS
# ------------------------------------------------------------------------------
# Widget definitions
tmux-sessionizer-widget() {
    zle clear-screen
    tmux-sessionizer
    zle reset-prompt
}

tmux-workflow-widget() {
    zle clear-screen
    tmux new-session -As WORKFLOW
    zle reset-prompt
}

yazi-widget() {
    zle clear-screen
    y
    zle clear-screen
    zle reset-prompt
}

# Register widgets
zle -N tmux-sessionizer-widget
zle -N tmux-workflow-widget
zle -N yazi-widget

# Key bindings
bindkey '^F' tmux-sessionizer-widget               # Ctrl+F
bindkey '^E' tmux-workflow-widget                  # Ctrl+E
bindkey '^Y' yazi-widget                           # Ctrl+Y
bindkey -s '^P' "clear; czpush\n"                 # Ctrl+P

# Standard bindings
bindkey '^I' expand-or-complete          # Tab
bindkey '^U' accept-line                 # Ctrl+U
bindkey '^L' autosuggest-accept          # Ctrl+L
bindkey '^G' clear-screen                # Ctrl+G

# ------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# ------------------------------------------------------------------------------
export SUDO_PROMPT="ENTER YOUR PASSWORD: "
export TERM=$ZSH_TMUX_TERM
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="thorium-browser"
export UV_LINK_MODE=copy
export RUFF_CACHE_DIR="$HOME/.cache/ruff"
export COMPOSE_BAKE=true

# Path configuration
typeset -U PATH path
path=(
    ~/.dotfiles/personal/sh
    ~/.local/bin
    ~/.local/scripts
    ~/.local/share
    ~/.cargo/bin
    $path
)

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
alias v="nvim"
alias zc="source ~/.zshrc"
alias mv="mv -vi"
alias rm="rm -rvi"
alias cp="cp -rvi"
alias mkdir="mkdir -pv"
alias s="clear; eza --long --header --icons=always --all --level=1 --group-directories-first --no-time"
alias l=s; alias ls=s
alias pwdcp="pwd|tr -d '\n'|xclip -selection clipboard"
alias untar="tar -xvvf"
alias zz="zip -r"; alias uz="unzip"
alias orph="yay -Rns \$(yay -Qdtq)"

function mirror-update() {
  sudo reflector \
    --protocol https \
    --age 72 \
    --sort rate \
    --latest 15 \
    --country Germany,Russia,Netherlands \
    --exclude '.*(lcarilla\.de|kumi\.systems|soulharsh007\.dev|unixpeople\.org).*' \
    --download-timeout 20 \
    --connection-timeout 10 \
    --verbose \
    --save /etc/pacman.d/mirrorlist
}

function grub-update() {
  sudo grub-mkconfig -o /boot/grub/grub.cfg && \
}

# ------------------------------------------------------------------------------
# TOOL INITIALIZATIONS
# ------------------------------------------------------------------------------
# Zoxide setup
eval "$(zoxide init zsh)"

# Yazi wrapper function
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
