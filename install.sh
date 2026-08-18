#!/bin/bash
set -e

DEST="$HOME/.config/omarchy/plugins/com.user.doom"
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "Installing omarchy-doom..."

# Check for doom binary
if ! command -v doomretro &>/dev/null; then
  echo "doomretro not found, installing..."
  sudo pacman -S --noconfirm doomretro
fi

# Create doomretro config with windowed defaults
CFG="$HOME/.config/doomretro/doomretro.cfg"
if [ ! -f "$CFG" ]; then
  echo "Creating doomretro config..."
  mkdir -p "$(dirname "$CFG")"
  cat > "$CFG" << 'EOF'
vid_fullscreen                   off
vid_widescreen                   on
vid_borderlesswindow             off
vid_screenresolution             desktop
vid_windowpos                    centered
vid_windowsize                   960x600
r_screensize                     8
EOF
else
  # Patch existing config to windowed
  sed -i 's/^vid_fullscreen\s\+on$/vid_fullscreen                   off/' "$CFG" 2>/dev/null
fi

# Add Hyprland window rule if not present
HYPR_FILE="$HOME/.config/hypr/hyprland.lua"
if [ -f "$HYPR_FILE" ] && ! grep -q "doomretro" "$HYPR_FILE"; then
  echo "Adding Hyprland window rule..."
  echo "" >> "$HYPR_FILE"
  echo "-- Doom: float and size" >> "$HYPR_FILE"
  echo 'hl.window_rule({ match = { class = "doomretro" }, float = true, size = { 960, 600 }, opaque = true })' >> "$HYPR_FILE"
  hyprctl reload 2>/dev/null
fi

# Copy plugin
mkdir -p "$DEST"
cp "$SRC/manifest.json" "$SRC/Widget.qml" "$DEST/"

echo ""
echo "Installed to $DEST"
echo "Restarting shell..."
omarchy-shell shell rescanPlugins
echo ""
echo "You'll need a Doom WAD file to play. Place it in ~/Games/doom/"
