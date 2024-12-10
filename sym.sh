#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Сброс цвета

# Лог-файл
LOG_FILE="$HOME/.dotfiles_stow.log"

# Константы
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

# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

# Функция обработки ошибок
exit_with_error() {
    echo -e "${RED}Ошибка: $1${NC}"
    log_message "Ошибка: $1"
    [ -n "$2" ] && log_message "Подробности: $2"
    exit 1
}

# Удаление симлинков
delink_directory() {
    local dir="$1"
    local target="$2"

    if [ -d "$dir" ]; then
        echo -e "${BLUE}Удаление симлинков из $target...${NC}"
        if ! stow -D --dir="$I3_DIR" --target="$target" "$(basename "$dir")"; then
            exit_with_error "Ошибка при удалении симлинков для $dir" "$(stow -D --dir="$I3_DIR" --target="$target" "$(basename "$dir")" 2>&1)"
        fi
        log_message "Симлинки из $dir успешно удалены из $target."
    else
        exit_with_error "Директория $dir не найдена."
    fi
}

# Функция stow
stow_directory() {
    local dir="$1"
    local target="$2"

    if [ ! -d "$dir" ]; then
        exit_with_error "Директория $dir отсутствует."
    fi

    if [ ! -d "$target" ]; then
        echo -e "${BLUE}Создаётся директория $target...${NC}"
        mkdir -p "$target" || exit_with_error "Не удалось создать директорию $target"
    fi

    echo -e "${BLUE}Создание симлинков из $dir в $target...${NC}"
    if ! stow --dir="$I3_DIR" --target="$target" "$(basename "$dir")"; then
        exit_with_error "Не удалось создать симлинки из $dir в $target" "$(stow --dir="$I3_DIR" --target="$target" "$(basename "$dir")" 2>&1)"
    fi
    log_message "Симлинки из $dir успешно созданы в $target."
}

# Основная логика
delink_mode=false

for arg in "$@"; do
    case $arg in
    -d)
        delink_mode=true
        ;;
    -h)
        echo "Использование: $(basename "$0") [--delink] [--help]"
        echo "  -d   Удалить существующие симлинки."
        echo "  -h   Показать это сообщение."
        exit 0
        ;;
    *)
        exit_with_error "Неизвестный аргумент: $arg"
        ;;
    esac
done

if [ "$delink_mode" = true ]; then
    delink_directory "$BIN_DIR" "$TARGET_BIN"
    delink_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    delink_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    delink_directory "$HOME_DIR" "$TARGET_HOME"
    echo -e "${GREEN}Все симлинки успешно удалены.${NC}"
    log_message "Все симлинки успешно удалены."
else
    stow_directory "$BIN_DIR" "$TARGET_BIN"
    stow_directory "$SCRIPTS_DIR" "$TARGET_SCRIPTS"
    stow_directory "$CONFIG_DIR" "$TARGET_CONFIG"
    stow_directory "$HOME_DIR" "$TARGET_HOME"
    echo -e "${GREEN}Все директории успешно связаны симлинками.${NC}"
    log_message "Все директории успешно связаны симлинками."
fi

echo "Нажмите Enter для выхода..."
read
