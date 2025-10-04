#!/bin/sh
# Random wallpaper selector for Labwc sessions.

WALLPAPER_DIRS="${HOME}/.config/hypr/wallpaper ${HOME}/Pictures/Wallpapers"

# Build list of candidate images
wallpapers=$(find ${WALLPAPER_DIRS} -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.bmp' \) 2>/dev/null)

if [ -z "${wallpapers}" ]; then
  echo "[labwc] No wallpapers found" >&2
  exit 0
fi

# Choose a random wallpaper
chosen=$(printf '%s
' "${wallpapers}" | sort -R | head -n1)

# Restart swaybg with the selected image
pkill -x swaybg 2>/dev/null
swaybg -m fill -i "${chosen}" &

logger -t labwc-wallpaper "Wallpaper set to $(basename "${chosen}")"
