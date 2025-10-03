#!/bin/bash

# Workspace assignment script for kanshi
# Called when connecting external monitors via USB-C

# Wait for Hyprland to register the monitors
sleep 2

# First create all workspaces to ensure they exist
for i in {1..22}; do
    hyprctl dispatch workspace $i >/dev/null 2>&1
done

# Find monitor names dynamically
monitors=$(hyprctl monitors -j)
left_monitor=""
right_monitor=""

for row in $(echo "$monitors" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    name=$(_jq '.name')
    serial=$(_jq '.serial')

    # Skip laptop display
    if [[ "$name" == "eDP-1" ]]; then
        continue
    fi

    # Right monitor has serial ending in 2281
    if [[ "$serial" == *"2281" ]]; then
        right_monitor="$name"
    # Left monitor has serial ending in 2448
    elif [[ "$serial" == *"2448" ]]; then
        left_monitor="$name"
    fi
done

# Assign workspaces according to configuration:
# Left monitor (DP-1): workspaces 1-10
if [[ -n "$left_monitor" ]]; then
    for i in {1..10}; do
        hyprctl dispatch moveworkspacetomonitor $i "$left_monitor" >/dev/null 2>&1
    done
    echo "Assigned workspaces 1-10 to $left_monitor"
fi

# Right monitor (DP-2): workspaces 11-20
if [[ -n "$right_monitor" ]]; then
    for i in {11..20}; do
        hyprctl dispatch moveworkspacetomonitor $i "$right_monitor" >/dev/null 2>&1
    done
    echo "Assigned workspaces 11-20 to $right_monitor"
fi

# Laptop screen gets workspaces 21-22
for i in 21 22; do
    hyprctl dispatch moveworkspacetomonitor $i eDP-1 >/dev/null 2>&1
done
echo "Assigned workspaces 21-22 to eDP-1"