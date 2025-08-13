#!/usr/bin/env bash
# Simplified NixOS deployment using passwordless nixos-rebuild

set -euo pipefail

CONFIG_DIR="/home/chris/projects/human-oriented-environment/configs/nixos-new"

echo "=== NixOS LLM Workstation Deployment ==="
echo "Using nixos-rebuild with configuration path..."
echo ""

echo "This will deploy the modular LLM-orchestrated workstation configuration."
echo "The build may take 15-30 minutes depending on what needs to be downloaded."
echo ""

read -p "Proceed with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

echo "Building new configuration (this may take some time)..."
echo "Configuration source: $CONFIG_DIR"
echo ""

# Use nixos-rebuild with our configuration directory
sudo nixos-rebuild switch -I nixos-config="$CONFIG_DIR/configuration.nix"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "The new configuration has been built and activated."
echo "Key changes:"
echo "  - Hyprland Wayland desktop environment installed"
echo "  - Comprehensive development tools available"
echo "  - Hardware optimizations for ThinkPad P16 Gen 2"
echo "  - Security hardening applied"
echo ""
echo "Next steps:"
echo "  1. Reboot to start using the Hyprland desktop environment"
echo "  2. Log in to the graphical session"
echo "  3. Configure Home Manager for user-level settings"
echo ""
echo "To reboot now: sudo reboot"