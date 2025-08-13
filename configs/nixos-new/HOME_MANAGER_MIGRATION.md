# Home Manager Migration Guide

This guide will help you migrate from embedded Home Manager configuration to standalone Home Manager.

## Files Created:
- `home.nix` - Standalone Home Manager configuration (extracted from system config)
- `configuration-system.nix` - Clean system configuration without user packages
- `HOME_MANAGER_MIGRATION.md` - This guide

## Migration Steps:

### 1. Install Standalone Home Manager
```bash
# Add the Home Manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --update

# Install Home Manager
nix-shell '<home-manager>' -A install
```

### 2. Set Up Home Manager Configuration
```bash
# Create the config directory
mkdir -p ~/.config/home-manager

# Copy the standalone config
cp /home/chris/projects/human-oriented-environment/configs/nixos-new/home.nix ~/.config/home-manager/home.nix

# Create the hyprland script directory and copy the script
mkdir -p ~/.config/hypr/scripts
cp /home/chris/projects/human-oriented-environment/configs/scripts/start-swayidle.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/start-swayidle.sh
```

### 3. Deploy Clean System Configuration
```bash
# Test the clean system configuration
sudo nixos-rebuild test -I nixos-config=/home/chris/projects/human-oriented-environment/configs/nixos-new/configuration-system.nix

# If successful, copy to /etc/nixos/
sudo cp /home/chris/projects/human-oriented-environment/configs/nixos-new/configuration-system.nix /etc/nixos/configuration.nix

# Deploy system configuration
sudo nixos-rebuild switch
```

### 4. Deploy Home Manager Configuration
```bash
# Apply Home Manager configuration
home-manager switch
```

### 5. Verify Everything Works
```bash
# Check that all your applications are available
which google-chrome
which dolphin
which btop
which starship

# Test git configuration
git config --list | grep user.name

# Test aliases
ls  # Should use eza
ll  # Should use eza -la
```

## What Changed:

### System Configuration (now clean):
- ✅ Only system-wide packages (kitty, wofi, qt support)
- ✅ Core services (openssh, pipewire, hyprland)
- ✅ Hardware and networking configuration
- ❌ No user packages (moved to Home Manager)
- ❌ No user dotfiles (moved to Home Manager)

### Home Manager Configuration (now standalone):
- ✅ All user applications (google-chrome, development tools, qt apps)
- ✅ Dotfiles (bash config, git config, starship, hyprland)
- ✅ Shell aliases and custom prompt
- ✅ Modern CLI tool configurations

## Benefits:
1. **Clean separation** - System vs user concerns
2. **No sudo needed** for user configuration changes
3. **Multi-user friendly** - Each user can have their own config
4. **Standard approach** - Following NixOS best practices
5. **Flexibility** - Modify user config without system rebuilds

## Rollback Plan:
If anything goes wrong, you can revert to the current working configuration:
```bash
sudo nixos-rebuild switch -I nixos-config=/home/chris/projects/human-oriented-environment/configs/nixos-new/configuration-simple.nix
```

## Future Workflow:
- **System changes**: Edit `/etc/nixos/configuration.nix` → `sudo nixos-rebuild switch`
- **User changes**: Edit `~/.config/home-manager/home.nix` → `home-manager switch`
- **Hyprland config**: Edit `~/.config/hypr/hyprland.conf` → Restart Hyprland session