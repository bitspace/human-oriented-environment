#!/usr/bin/env bash
# NixOS Configuration Deployment Script
# Deploy the modular LLM-orchestrated workstation configuration

set -euo pipefail

# Get the actual user (even when run with sudo)
if [[ -n "${SUDO_USER:-}" ]]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_HOME="/home/$SUDO_USER"
else
    ACTUAL_USER="$(whoami)"
    ACTUAL_HOME="$HOME"
fi

CONFIG_DIR="/home/chris/projects/human-oriented-environment/configs/nixos-new"
NIXOS_CONFIG_DIR="/etc/nixos"

echo "=== NixOS LLM Workstation Deployment ==="
echo "This will replace the current minimal NixOS configuration with a comprehensive"
echo "development workstation optimized for LLM orchestration."
echo ""

# Must be run as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root or with sudo."
    echo "Usage: sudo ./deploy.sh"
    exit 1
fi

echo "Configuration modules to be deployed:"
echo "  - base.nix: Core system optimizations and packages"
echo "  - hardware.nix: ThinkPad P16 Gen 2 hardware support"  
echo "  - networking.nix: Enhanced networking and security"
echo "  - desktop.nix: Hyprland Wayland desktop environment"
echo "  - development.nix: Comprehensive development tools"
echo "  - security.nix: Security hardening and policies"
echo ""

# Backup current configuration if not already backed up
BACKUP_DIR="$ACTUAL_HOME/nixos-config-backup-$(date +%Y%m%d)"
if [[ ! -f "$BACKUP_DIR/configuration.nix" ]]; then
    echo "Creating backup of current configuration in $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/nixos/* "$BACKUP_DIR/"
    chown -R "$ACTUAL_USER:users" "$BACKUP_DIR"
    echo "Backup created successfully."
else
    echo "Backup already exists at $BACKUP_DIR"
fi

echo ""
echo "Deployment steps:"
echo "1. Copy new configuration to /etc/nixos/"
echo "2. Run nixos-rebuild switch"
echo "3. Reboot to activate Hyprland desktop"
echo ""

read -p "Proceed with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

# Copy configuration files
echo "Copying configuration files..."
cp -r "$CONFIG_DIR"/* "$NIXOS_CONFIG_DIR/"

echo "Building new configuration (this may take some time)..."
nixos-rebuild switch

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "The new configuration has been built and activated."
echo "Key changes:"
echo "  - Hyprland Wayland desktop environment installed"
echo "  - Comprehensive development tools available"
echo "  - Hardware optimizations for ThinkPad P16 Gen 2"
echo "  - Security hardening applied"
echo "  - LLM orchestration tools prepared"
echo ""
echo "Next steps:"
echo "  1. Reboot to start using the Hyprland desktop environment"
echo "  2. Log in to the graphical session"
echo "  3. Configure Home Manager for user-level settings"
echo ""
echo "To reboot now: sudo reboot"
echo "To reboot later: The system will continue to work with current session"