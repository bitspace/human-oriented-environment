#!/bin/bash
# Random wallpaper selector for Hyprland

WALLPAPER_DIR="$HOME/.config/hypr/wallpaper"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Find all supported image files
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null)

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Select random wallpaper
selected_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"

# Generate new hyprpaper config
cat > "$HYPRPAPER_CONFIG" << EOF
# Auto-generated wallpaper configuration
$(for wallpaper in "${wallpapers[@]}"; do
    echo "preload = $wallpaper"
done)

wallpaper = ,$selected_wallpaper

splash = false
ipc = on
EOF

echo "Selected wallpaper: $(basename "$selected_wallpaper")"

# If hyprpaper is running, reload it
if pgrep -x hyprpaper > /dev/null; then
    hyprctl hyprpaper wallpaper ",$selected_wallpaper"
fi