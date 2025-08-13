# NixOS Configuration Archive - Home Manager Migration
**Date**: 2025-08-13  
**Purpose**: Archive of configurations before Home Manager migration

## What happened:
- Successfully migrated from embedded Home Manager to standalone Home Manager
- Separated system-wide and user-specific configurations
- Moved from complex modular structure to clean, simple approach

## Files in this archive:

### Working Configurations (before migration):
- `configuration-simple.nix` - Final working embedded Home Manager config
- `configuration-minimal.nix` - Minimal working config 
- `current-working.nix` - Intermediate working version

### Modular Structure (abandoned due to conflicts):
- `configuration-modular.nix` - Import-based modular configuration (had package conflicts)
- `modules/base.nix` - Core system settings
- `modules/desktop.nix` - Desktop environment (had GNOME dependencies)
- `modules/development.nix` - Development tools (too many packages)
- `modules/hardware.nix` - Hardware-specific settings
- `modules/networking.nix` - Network configuration
- `modules/security.nix` - Security hardening

### Issues with archived configs:
- **Package conflicts**: Same packages defined in multiple modules
- **GNOME dependencies**: desktop.nix included gnome-keyring, thunar, etc.
- **Complexity**: Hard to maintain and debug
- **User/system mixing**: User packages in system config

## Current working setup:
- **System config**: `/etc/nixos/configuration.nix` (from `configuration-system.nix`)
- **User config**: `~/.config/home-manager/home.nix`
- **Clean separation**: System vs user concerns properly separated

## Migration outcome:
✅ Standalone Home Manager working  
✅ Clean system configuration  
✅ Qt applications (Dolphin, Okular, Gwenview)  
✅ Modern CLI tools (eza, bat, fd, ripgrep, delta, starship)  
✅ Proper NixOS workflow: `sudo nixos-rebuild switch` vs `home-manager switch`  

These files are kept for reference but should not be used for future configurations.