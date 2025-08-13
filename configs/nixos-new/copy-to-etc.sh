#!/bin/bash
# Script to copy clean system configuration to /etc/nixos/

echo "Backing up existing configuration..."
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup-$(date +%Y%m%d-%H%M%S)

echo "Copying clean system configuration..."
sudo cp /home/chris/projects/human-oriented-environment/configs/nixos-new/configuration-system.nix /etc/nixos/configuration.nix

echo "Verifying copy..."
ls -la /etc/nixos/configuration.nix

echo "Testing configuration..."
sudo nixos-rebuild test

echo "Done! You can now run 'sudo nixos-rebuild switch' to apply permanently."