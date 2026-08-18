#!/bin/bash
set -e

echo "Uninstalling omarchy-doom..."

# Remove plugin
rm -rf "$HOME/.config/omarchy/plugins/com.user.doom"

# Remove Hyprland window rule
HYPR_FILE="$HOME/.config/hypr/hyprland.lua"
if [ -f "$HYPR_FILE" ]; then
  sed -i '/-- Doom: float and size/d' "$HYPR_FILE"
  sed -i '/doomretro.*float.*size/d' "$HYPR_FILE"
fi

# Optionally remove WAD folder
if [ -d "$HOME/Games/doom" ]; then
  read -p "Remove ~/Games/doom/ with WAD files? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/Games/doom"
    echo "Removed ~/Games/doom/"
  fi
fi

# Optionally remove doomretro config
if [ -f "$HOME/.config/doomretro/doomretro.cfg" ]; then
  read -p "Remove doomretro config? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/doomretro"
    echo "Removed doomretro config"
  fi
fi

# Optionally remove doomretro
if command -v doomretro &>/dev/null; then
  read -p "Uninstall doomretro? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -Rns doomretro
  fi
fi

echo "Done. Restarting shell..."
omarchy-shell shell rescanPlugins
