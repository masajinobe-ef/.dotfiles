#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/.dotfiles"
I3_DIR="$DOTFILES_DIR/i3"

BIN_DIR="$I3_DIR/bin"
SCRIPTS_DIR="$I3_DIR/scripts"
CONFIG_DIR="$I3_DIR/config"
HOME_DIR="$I3_DIR/home"

TARGET_BIN="$HOME/.local/bin"
TARGET_SCRIPTS="$HOME/.local/scripts"
TARGET_CONFIG="$HOME/.config"
TARGET_HOME="$HOME"

exit_with_error() {
    echo -e "${RED}Error: $1${NC}"
    [ -n "$2" ] && echo "Details: $2"
    exit 1
}

delink_directory() {
    local dir="$1"
    local target="$2"
    if [ -d "$dir" ]; then
        echo -e "${BLUE}Removing symlinks from $target...${NC}"
        if ! stow -D --dir="$I3_DIR" --target="$target" "$(basename "$dir")"; then
            exit_with_error "Error removing symlinks for $dir" "$(stow -D --dir="$I3_DIR" --target="$target" "$(basename "$dir")" 2>&1)"
        fi
    else
        exit_with_error "Directory $dir not found."
    fi
}

stow_directory() {
    local dir="$1"
    local target="$2"
    [ ! -d "$dir" ] && exit_with_error "Directory $dir is missing."

    if [ ! -d "$target" ]; then
        echo -e "${BLUE}Creating directory $target...${NC}"
        if ! mkdir -p "$target"; then
            exit_with_error "Failed to create directory $target. Check permissions."
        fi
    else
        echo -e "${GREEN}Directory $target already exists.${NC}"
    fi

    echo -e "${BLUE}Creating symlinks from $dir to $target...${NC}"
    if ! stow --dir="$I3_DIR" --target="$target" "$(basename "$dir")"; then
        exit_with_error "Failed to create symlinks from $dir to $target" "$(stow --dir="$I3_DIR" --target="$target" "$(basename "$dir")" 2>&1)"
    fi
}

delink_mode=false

for arg in "$@"; do
    case $arg in
    -d)
        delink_mode=true
        ;;
    -h)
        echo "Usage: $(basename "$0") [-d] [-m] [-h]"
        echo "  -d   Remove existing symlinks."
        exit 0
        ;;
    *)
        exit_with_error "Unknown argument: $arg"
        ;;
    esac
done

if [ "$delink_mode" = true ]; then
    delink_directory "$BIN_DIR" "$TARGET_BIN"
    delink_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    delink_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    delink_directory "$HOME_DIR" "$TARGET_HOME"
    echo -e "${GREEN}All symlinks successfully removed.${NC}"
else
    stow_directory "$BIN_DIR" "$TARGET_BIN"
    stow_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    stow_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    stow_directory "$HOME_DIR" "$TARGET_HOME"
    echo -e "${GREEN}All directories successfully symlinked.${NC}"
fi

read -p "Press Enter to exit..."
