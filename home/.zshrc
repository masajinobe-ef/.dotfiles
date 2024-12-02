#!/bin/zsh

# ==============================================================================
#                                Tmux Settings
# ==============================================================================

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=true

# ==============================================================================
#                            Powerlevel10k Instant Prompt
# ==============================================================================

[[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# ==============================================================================
#                                 Oh My Zsh Setup
# ==============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# ==============================================================================
#                        Zsh Autosuggestions Strategy
# ==============================================================================

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ==============================================================================
#                             Oh My Zsh Auto Update
# ==============================================================================

zstyle ":omz:update" mode auto
zstyle ":omz:update" frequency 7

# ==============================================================================
#                                  Zsh General Updates
# ==============================================================================

export UPDATE_ZSH_DAYS=7

# ==============================================================================
#                          Magic Functions & Corrections
# ==============================================================================

DISABLE_UNTRACKED_FILES_DIRTY="true"

# ==============================================================================
#                            History Timestamp Format
# ==============================================================================

HIST_STAMPS="dd/mm/yyyy"

# ==============================================================================
#                                 Plugins to Load
# ==============================================================================

plugins=(
  git
  tmux
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  zsh-autopair
)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh

# ==============================================================================
#                              Environment Variables
# ==============================================================================

export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="chromium"

export LANG=en_US.UTF-8
export ARCHFLAGS="-arch x86_64"
export TERM="tmux-256color"
export RUST_BACKTRACE=1

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

alias n="nvim"
alias v="nvim"
alias vim="nvim"

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
alias pkgS="pacman -Q | fzf"
alias pkgI="pacman -Slq | fzf --multi --preview 'cat <(pacman -Si {1}) <(pacman -Fly {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias pkgU="pacman -Qq | fzf --multi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias yayI="yay -Slq | fzf -m --preview 'cat <(yay -Si {1}) <(yay -Fl {1} | awk \"{print \$2}\")' | xargs -ro  yay -S"

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
#                                Additional Configurations
# ==============================================================================

# Load Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load Zoxide
eval "$(zoxide init zsh)"

# Load NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Load Yandex API (if exists)
if [ -f '/home/masa/yandex-cloud/path.bash.inc' ]; then source '/home/masa/yandex-cloud/path.bash.inc'; fi
if [ -f '/home/masa/yandex-cloud/completion.zsh.inc' ]; then source '/home/masa/yandex-cloud/completion.zsh.inc'; fi

