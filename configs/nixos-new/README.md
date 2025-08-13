# NixOS Configuration - Current Working Files

## Active Configurations:
- `configuration-system.nix` - **System-wide NixOS configuration** (copied to `/etc/nixos/configuration.nix`)
- `home.nix` - **User configuration template** (copied to `~/.config/home-manager/home.nix`)
- `hardware-configuration.nix` - Hardware-specific settings

## Utility Files:
- `copy-to-etc.sh` - Script to copy system config to `/etc/nixos/`
- `test-config.sh` - Configuration testing script
- `HOME_MANAGER_MIGRATION.md` - Migration guide and instructions
- `DEPLOYMENT_SUMMARY.md` - Deployment notes

## Current Workflow:
- **System changes**: Edit `/etc/nixos/configuration.nix` → `sudo nixos-rebuild switch`
- **User changes**: Edit `~/.config/home-manager/home.nix` → `home-manager switch`

## Archive:
Old configurations moved to: `../archive/20250813-home-manager-migration/`