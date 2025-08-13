#!/usr/bin/env bash
# Test script to validate NixOS configuration before deployment

set -euo pipefail

CONFIG_DIR="/home/chris/projects/human-oriented-environment/configs/nixos-new"

echo "=== NixOS Configuration Validation ==="
echo ""

# Check if all required files exist
echo "Checking required files..."
REQUIRED_FILES=(
    "configuration.nix"
    "hardware-configuration.nix"
    "modules/base.nix"
    "modules/hardware.nix"
    "modules/networking.nix"
    "modules/desktop.nix"
    "modules/development.nix"
    "modules/security.nix"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$CONFIG_DIR/$file" ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

echo ""
echo "Testing configuration syntax..."

# Change to config directory for relative imports
cd "$CONFIG_DIR"

# Test configuration parsing
if nix-instantiate --parse configuration.nix > /dev/null 2>&1; then
    echo "✓ Configuration syntax is valid"
else
    echo "✗ Configuration syntax error"
    nix-instantiate --parse configuration.nix
    exit 1
fi

# Test if configuration can be built (dry-run)
echo ""
echo "Testing configuration build (this may take a moment)..."
if nix-instantiate '<nixpkgs/nixos>' -A system --arg configuration './configuration.nix' > /dev/null 2>&1; then
    echo "✓ Configuration builds successfully"
else
    echo "✗ Configuration build failed"
    echo "Error details:"
    nix-instantiate '<nixpkgs/nixos>' -A system --arg configuration './configuration.nix' 2>&1 | head -20
    exit 1
fi

echo ""
echo "=== Validation Complete ==="
echo "Configuration is ready for deployment!"
echo ""
echo "To deploy: sudo ./deploy.sh"