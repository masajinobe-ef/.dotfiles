#!/usr/bin/env bash

set -euo pipefail
trap 'echo "Error in line $LINENO"; exit 1' ERR

echo "----------------------------------------------------"
echo "UPDATING SYSTEM"
echo "----------------------------------------------------"

yay -Syu

echo ""
echo "----------------------------------------------------"
echo "CLEARING PACMAN CACHE"
echo "----------------------------------------------------"

if ! command -v paccache &>/dev/null; then
    echo "Installing pacman-contrib..."
    yay -S --needed pacman-contrib
fi

pacman_cache_space_used="$(du -sh /var/cache/pacman/pkg/)"
echo "Space currently in use: $pacman_cache_space_used"
echo ""
echo "Clearing Cache, leaving newest 2 versions:"
sudo paccache -vrk2 # paccache still needs sudo
echo ""
echo "Clearing all uninstalled packages:"
sudo paccache -ruk0

echo ""
echo "----------------------------------------------------"
echo "CLEARING HOME CACHE"
echo "----------------------------------------------------"

home_cache_used="$(du -sh ~/.cache)"
if [ -d "$HOME/.cache" ]; then
    rm -rf ~/.cache/*
    echo "Clearing ~/.cache/..."
    echo "Space saved: $home_cache_used"
else
    echo ".cache directory not found"
fi

echo ""
echo "----------------------------------------------------"
echo "CLEARING SYSTEM LOGS"
echo "----------------------------------------------------"

sudo journalctl --vacuum-time=1h
echo ""

echo ""
echo "----------------------------------------------------"
echo "OPTIONAL: Clean package cache? (y/N)"
echo "----------------------------------------------------"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    yay -Scc
fi

echo "System maintenance completed!"
