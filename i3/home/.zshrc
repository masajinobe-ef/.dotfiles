#!/bin/zsh

# ==============================================================================
#                                 Zsh
# ==============================================================================

# Zsh settings
export DISABLE_AUTO_TITLE="true"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export UPDATE_ZSH_DAYS=7
export ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC="true"

# History
export HISTFILE="$HOME/.zsh_history"
export HIST_STAMPS="dd/mm/yyyy"
export HISTSIZE=10000000
export SAVEHIST=10000000
unsetopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_GLOB
setopt LONG_LIST_JOBS
setopt AUTO_CD
setopt AUTO_CONTINUE
setopt HIST_VERIFY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt TRANSIENT_RPROMPT
setopt INTERACTIVE_COMMENTS

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
zstyle ":omz:update" mode auto
zstyle ":omz:update" frequency 7

# tmux
bindkey -s '^e' 'tmux has-session -t WORKFLOW 2>/dev/null && tmux attach-session -t WORKFLOW || tmux new-session -s WORKFLOW -n "zsh" "zsh"\n'

# tmux-sessionizer
bindkey -s '^f' "tmux-sessionizer\n"

# ==============================================================================
#                                 Plugins to Load
# ==============================================================================

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Zsh completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

# ==============================================================================
#                              Environment Variables
# ==============================================================================

VIM="nvim"
TERMINAL="alacritty"

export LANG="en_US.UTF-8"
export XDG_SESSION_TYPE="x11"
export SUDO_PROMPT="passwd: "

export EDITOR=$VIM
export SUDO_EDITOR=$VIM
export VISUAL=$VIM
export GIT_EDITOR=$VIM

export TERMINAL=$TERMINAL
export TERM_PROGRAM=$TERMINAL
export TERM="screen-256color"

export BROWSER="thorium-browser"

export CARGO="$HOME/.cargo/bin"
export JAVA="/usr/lib/jvm/java-23-openjdk"
export SCRIPTS="$HOME/.local/scripts"
export BIN="$HOME/.local/bin"

export PATH="$CARGO:$JAVA:$SCRIPTS:$BIN:$PATH"

. "$HOME/.cargo/env"

# ==============================================================================
#                                    Aliases
# ==============================================================================

alias aliases="alias | fzf"

alias zc="source ~/.zshrc"

alias n=$VIM
alias v=$VIM
alias vim=$VIM

alias g="git"
alias lg="lazygit"

alias b="bat"

alias grep="rg"

alias c="clear"
alias cls="clear"
alias mv="mv -v"
alias rm="rm -rfv"
alias cp="cp -vr"
alias mkdir="mkdir -p"

alias tgz="tar -cvvzf"
alias tbz2="tar -cvvjf"
alias utgz="tar -xvvzf"
alias utbz2="tar -xvvjf"
alias mktar="tar -cvvf"
alias untar="tar -xvvf"
alias zz="zip -r"
alias uz="unzip"

alias font="fc-list : family | fzf"

alias orph="sudo pacman -Rns \$(pacman -Qdtq)"
alias pkgs="pacman -Q | fzf"
alias pkgi="pacman -Slq | fzf --multi --preview 'cat <(pacman -Si {1}) <(pacman -Fly {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias pkgu="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"

alias yayi="yay -Slq | fzf -m --preview 'cat <(yay -Si {1}) <(yay -Fl {1} | awk \"{print \$2}\")' | xargs -ro  yay -S"

alias l="clear; eza --long --header --tree --icons=always --all --level=1 --group-directories-first --no-permissions --no-user --no-time --no-filesize"
alias ls="l"

alias dun='killall dunst && dunst & notify-send "cool2" "yeah it is working" && notify-send "cool2" "yeah it is working"'

alias ipv4="ip addr show | grep 'inet ' | grep -v '127.0.0.1' | cut -d' ' -f6 | cut -d/ -f1"
alias ipv6="ip addr show | grep 'inet6 ' | cut -d ' ' -f6 | sed -n '2p'"

alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias mirror-update="sudo reflector --verbose --protocol https --age 12 --sort rate --latest 10 --country France,Germany,Finland,Russia,Netherlands --save /etc/pacman.d/mirrorlist"

# ==============================================================================
#                                  Functions
# ==============================================================================

# search
function zs() {
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then nvim {1} +{2}; else nvim +cw -q {+f}; fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$@"
}

# yazi
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ==============================================================================
#                                Load Modules
# ==============================================================================

# Load Powerlevel10k
[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load Zoxide
eval "$(zoxide init zsh)"

