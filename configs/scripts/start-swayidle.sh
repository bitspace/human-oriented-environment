#!/usr/bin/env bash
# Script to start swayidle with screen locking

# Log to help debug
echo "Starting swayidle at $(date)" >> /tmp/swayidle.log

# Start swayidle with screen locking
exec /run/current-system/sw/bin/swayidle -w \
    timeout 300 '/run/current-system/sw/bin/swaylock' \
    timeout 600 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep '/run/current-system/sw/bin/swaylock'