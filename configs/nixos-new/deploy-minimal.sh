#!/usr/bin/env bash
# Deploy minimal Hyprland configuration first, then add features incrementally

set -euo pipefail

CONFIG_DIR="/home/chris/projects/human-oriented-environment/configs/nixos-new"

echo "=== NixOS Minimal Hyprland Deployment ==="
echo ""
echo "This will deploy a minimal Hyprland desktop environment with:"
echo "  - Hyprland Wayland compositor"
echo "  - Basic desktop applications (Firefox, VS Code)"
echo "  - Essential development tools"
echo "  - Hardware optimizations"
echo ""
echo "After this succeeds, we can add more features incrementally."
echo ""

read -p "Proceed with minimal deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

echo "Building minimal configuration..."
sudo nixos-rebuild switch -I nixos-config="$CONFIG_DIR/configuration-minimal.nix"

echo ""
echo "=== Minimal Deployment Complete ==="
echo ""
echo "Basic Hyprland desktop environment is now installed."
echo "After reboot, you'll have:"
echo "  - Hyprland Wayland desktop"
echo "  - Firefox browser"
echo "  - VS Code editor"
echo "  - Basic development tools"
echo ""
echo "Next steps:"
echo "  1. Reboot: sudo reboot"
echo "  2. Log into Hyprland session"
echo "  3. Test basic functionality"
echo "  4. Add more features incrementally"
echo ""