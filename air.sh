#!/bin/bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="$HOME/.dotfiles_stow.log"

# Constants
STOW_CMD="stow"
DOTFILES_DIR="$(pwd)"
BRANCH="main" # Default branch

BIN_DIR="$DOTFILES_DIR/bin"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
HOME_DIR="$DOTFILES_DIR/home"

CONFIG_DIR="$DOTFILES_DIR/air/config"

TARGET_BIN="$HOME/.local/bin"
TARGET_SCRIPTS="$HOME/.local/scripts"
TARGET_CONFIG="$HOME/.config"
TARGET_HOME="$HOME"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Error handling function
exit_with_error() {
    local message="$1"
    local details="$2"
    echo -e "${RED}Error: $message${NC}"
    log_message "Error: $message"
    if [ -n "$details" ]; then
        log_message "Details: $details"
    fi
    exit 1
}

# Function for Git operations
git_operations() {
    cd "$DOTFILES_DIR" || exit_with_error "Could not change to directory $DOTFILES_DIR"

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_message "Not a Git repository: $DOTFILES_DIR"
        echo -e "${RED}Error: $DOTFILES_DIR is not a Git repository.${NC}"
        return
    fi

    git fetch
    if ! git diff --quiet HEAD origin/"$BRANCH"; then
        echo -e "${BLUE}Local repository is not up-to-date. Pulling changes...${NC}"
        if git pull --rebase origin "$BRANCH"; then
            echo -e "${GREEN}Repository successfully updated.${NC}"
            log_message "Repository successfully updated."
        else
            local error_details=$(git pull --rebase origin "$BRANCH" 2>&1)
            exit_with_error "Failed to pull changes" "$error_details"
        fi
    else
        echo -e "${BLUE}Repository is already up-to-date.${NC}"
        log_message "Repository is already up-to-date."
    fi

    git add .
    if ! git diff-index --quiet HEAD --; then
        git commit -m "Update configurations: $(date '+%Y-%m-%d %H:%M:%S')" || exit_with_error "Could not commit changes"
        if git push origin "$BRANCH"; then
            echo -e "${GREEN}Changes successfully pushed to the remote repository.${NC}"
            log_message "Changes successfully pushed to the remote repository."
        else
            local error_details=$(git push origin "$BRANCH" 2>&1)
            exit_with_error "Could not push changes" "$error_details"
        fi
    else
        echo -e "${BLUE}No changes to commit or push.${NC}"
        log_message "No changes to commit or push."
    fi
}

# Function to show usage
show_help() {
    echo "Usage: $(basename "$0") [--offline] [--help] [--delink]"
    echo
    echo "Options:"
    echo "  --offline    Skip Git operations."
    echo "  --help       Show this help message."
    echo "  --delink     Remove existing symlinks created by stow."
}

# Function to remove symlinks
delink_directory() {
    local dir="$1"
    local target="$2"

    if [ -d "$dir" ] && [ "$(ls -A "$dir")" ]; then
        echo -e "${BLUE}Removing symlinks for $dir from $target...${NC}"
        if $STOW_CMD -D --target="$target" "$(basename "$dir")"; then
            log_message "Successfully removed symlinks for $dir from $target"
        else
            local error_details=$($STOW_CMD -D --target="$target" "$(basename "$dir")" 2>&1)
            exit_with_error "Error removing symlinks for $dir from $target" "$error_details"
        fi
    else
        exit_with_error "Directory not found or empty: $dir"
    fi
}

# Check if stow is installed, and ask for installation if not
if ! command -v "$STOW_CMD" >/dev/null 2>&1; then
    echo -e "${BLUE}stow is not installed. Do you want to install it using pacman? (y/n)${NC}"
    read -r install_answer
    if [[ "$install_answer" == "y" ]]; then
        echo -e "${BLUE}Installing stow...${NC}"
        if sudo pacman -S --noconfirm stow; then
            echo -e "${GREEN}stow successfully installed.${NC}"
            log_message "stow successfully installed."
        else
            local error_details=$(sudo pacman -S --noconfirm stow 2>&1)
            exit_with_error "Could not install stow" "$error_details"
        fi
    else
        exit_with_error "Aborting due to missing stow installation."
    fi
fi

# Parse arguments
offline_mode=false
delink_mode=false

for arg in "$@"; do
    case $arg in
    --offline)
        offline_mode=true
        shift
        ;;
    --help)
        show_help
        exit 0
        ;;
    --delink)
        delink_mode=true
        shift
        ;;
    *)
        exit_with_error "Unknown argument: $arg"
        ;;
    esac
done

# Perform Git operations unless offline mode is enabled
if [ "$offline_mode" = false ]; then
    git_operations
fi

# Function to stow a directory to a specific target
stow_directory() {
    local dir="$1"
    local target="$2"

    if [ ! -d "$target" ]; then
        echo -e "${GREEN}Target directory $target does not exist. Creating it...${NC}"
        if mkdir -p "$target"; then
            log_message "Created target directory: $target"
        else
            exit_with_error "Could not create target directory" "$target"
        fi
    fi

    if [ -d "$dir" ] && [ "$(ls -A "$dir")" ]; then
        echo -e "${BLUE}Stowing $dir to $target...${NC}"

        local package_name=$(basename "$dir")
        overwrite_all=false
        skip_all=false

        for file in "$dir"/*; do
            local base_file=$(basename "$file")

            if [ "$skip_all" = true ]; then
                log_message "Skipping $base_file due to skip-all choice."
                continue
            fi

            if [ -L "$target/$base_file" ]; then
                continue
            elif [ -e "$target/$base_file" ]; then
                if [ "$overwrite_all" = true ]; then
                    log_message "Overwriting $base_file due to overwrite-all choice."
                else
                    echo -e "${RED}Conflict: $target/$base_file already exists. Do you want to overwrite it? (y/n/all/skip-all)${NC}"
                    read -r answer
                    case "$answer" in
                    y) ;; # Continue to overwrite
                    n)
                        echo -e "${GREEN}Skipping $base_file...${NC}"
                        log_message "Skipping $base_file due to user choice."
                        continue
                        ;;
                    all)
                        overwrite_all=true
                        log_message "Overwriting all subsequent conflicts."
                        ;;
                    skip-all)
                        skip_all=true
                        log_message "Skipping all subsequent conflicts."
                        continue
                        ;;
                    esac
                fi
            fi
        done

        if $STOW_CMD --target="$target" "$package_name"; then
            log_message "Successfully stowed $dir to $target"
        else
            local error_details=$($STOW_CMD --target="$target" "$package_name" 2>&1)
            exit_with_error "Error stowing $dir to $target" "$error_details"
        fi
    else
        exit_with_error "Directory not found or empty: $dir"
    fi
}

# Stow or delink based on the mode
if [ "$delink_mode" = true ]; then
    delink_directory "$BIN_DIR" "$TARGET_BIN"
    delink_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    delink_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    delink_directory "$HOME_DIR" "$TARGET_HOME"
else
    if [ ! -d "$BIN_DIR" ] || [ ! -d "$SCRIPTS_DIR" ] || [ ! -d "$CONFIG_DIR" ] || [ ! -d "$HOME_DIR" ]; then
        exit_with_error "One or more required directories (bin, scripts, config, home) do not exist."
    fi

    stow_directory "$BIN_DIR" "$TARGET_BIN"
    stow_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    stow_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    stow_directory "$HOME_DIR" "$TARGET_HOME"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}All directories stowed successfully.${NC}"
        log_message "All directories stowed successfully."
    fi
fi

echo "Press Enter to exit..."
read
