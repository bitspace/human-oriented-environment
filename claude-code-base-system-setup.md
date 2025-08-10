# Claude Code Base System Setup Guide

## Overview

This guide establishes a minimal but functional NixOS system with Claude Code installed, after which Claude Code can take over the majority of the remaining configuration work with user confirmation at critical decision points.

## Phase 1: Minimal NixOS Base System (45 minutes)

### Step 1: Create Installation Media
```bash
# Download NixOS minimal ISO
wget https://releases.nixos.org/nixos/24.05/nixos-minimal-24.05.latest-x86_64-linux.iso

# Create bootable USB (replace /dev/sdX with your USB device)
dd if=nixos-minimal-24.05.latest-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
```

### Step 2: Boot and Initial Setup
1. Boot from USB drive
2. Select "NixOS Installer" option
3. Wait for boot to complete

### Step 3: Connect to WiFi Network

**CRITICAL**: The live environment does not have network connectivity by default. You must connect to WiFi before proceeding.

**Method 1: Using wpa_supplicant (primary method for NixOS live environment)**
```bash
# Find your WiFi interface name
ip link show
# Look for interface like wlan0, wlp2s0, etc.

# Bring up the WiFi interface (replace wlan0 with your interface)
sudo ip link set wlan0 up

# Scan for available networks
sudo iw dev wlan0 scan | grep SSID

# Create wpa_supplicant configuration
wpa_passphrase "YOUR_WIFI_SSID" "YOUR_WIFI_PASSWORD" > /tmp/wpa_supplicant.conf

# Connect to network
sudo wpa_supplicant -B -i wlan0 -c /tmp/wpa_supplicant.conf

# Get IP address via DHCP
sudo dhcpcd wlan0

# Verify connection
ping -c 3 google.com
```

**Method 2: Using iwctl (if available)**
```bash
# Check if iwctl is available
which iwctl

# If available, use iwctl
iwctl
# In iwctl prompt:
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YOUR_WIFI_SSID"
# Enter password when prompted
quit

# Verify connection
ping -c 3 google.com
```

**Troubleshooting WiFi Connection:**
```bash
# Check if WiFi interface exists and is up
ip link show
sudo ip link set wlan0 up  # Replace wlan0 with your interface

# Check for wireless hardware
lspci | grep -i network
lsusb | grep -i wireless
rfkill list

# If WiFi is blocked by rfkill
sudo rfkill unblock wifi

# Check available wireless interfaces
iw dev

# If driver issues, try loading firmware
sudo modprobe iwlwifi  # For Intel cards
sudo modprobe ath9k    # For Atheros cards
sudo modprobe rtl8xxxu # For Realtek cards

# Check kernel messages for WiFi driver issues
dmesg | grep -i wifi
dmesg | grep -i wireless
```

**If WiFi Still Doesn't Work:**
```bash
# Alternative: Use ethernet connection temporarily
# Connect ethernet cable if available

# Or use USB tethering from phone
# Enable USB tethering on your phone, connect via USB
# Interface should appear as something like usb0
ip link show
sudo dhcpcd usb0
```

### Step 4: Partition the Drive
```bash
# Partition the NVMe drive
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB
parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100%

# Set boot flag on ESP partition
parted /dev/nvme0n1 -- set 1 esp on
```

### Step 5: Format Filesystems
```bash
# Format partitions
mkfs.fat -F 32 -n boot /dev/nvme0n1p1
mkfs.xfs -f -L nixos /dev/nvme0n1p2
mkswap -L swap /dev/nvme0n1p3

# Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon /dev/nvme0n1p3
```

### Step 6: Generate Hardware Configuration
```bash
# Generate initial configuration
nixos-generate-config --root /mnt

# This creates:
# - /mnt/etc/nixos/configuration.nix
# - /mnt/etc/nixos/hardware-configuration.nix
```

### Step 7: Create Minimal System Configuration

**CRITICAL CHECKPOINT**: Review and confirm the configuration below before proceeding.

Create `/mnt/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes and new nix command (required for modern NixOS)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Networking
  networking.hostName = "kudu6-nixos";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;  # Disable wpa_supplicant (conflicts with NetworkManager)

  # Time zone
  time.timeZone = "America/New_York";  # Adjust as needed

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";

  # User account
  users.users.chris = {  # Replace 'chris' with your username
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [];
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = false;  # Temporary for setup

  # Basic system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
  ];

  # Enable SSH for remote access (optional)
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # This value determines the NixOS release compatibility
  system.stateVersion = "24.05";
}
```

### Step 8: Install Base System
```bash
# Install NixOS
nixos-install

# Set root password when prompted
# Note: User password is NOT prompted during nixos-install

# Set user password manually after installation
nixos-enter --root /mnt
passwd chris  # Replace 'chris' with your username
exit

# Reboot into new system
reboot
```

### Step 9: Post-Installation Verification
After reboot, log in and verify:

```bash
# Check system info
uname -a
cat /etc/os-release

# Check NixOS version
nixos-version

# Verify user can sudo
sudo whoami

# Connect to WiFi in the installed system
sudo nmcli device wifi list
sudo nmcli device wifi connect "YOUR_WIFI_SSID" password "YOUR_WIFI_PASSWORD"

# Verify network connectivity
ping -c 3 google.com
```

**If NetworkManager WiFi connection fails:**
```bash
# Check NetworkManager status
sudo systemctl status NetworkManager

# Start NetworkManager if not running
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Check available interfaces
ip link show

# If WiFi interface is down
sudo ip link set wlan0 up  # Replace wlan0 with your interface

# Alternative: Use nmtui (text UI)
sudo nmtui

# Manual connection if needed
sudo wpa_supplicant -B -i wlan0 -c <(wpa_passphrase "SSID" "password")
sudo dhcpcd wlan0
```

## Phase 2: Claude Code Installation (15 minutes)

### Step 1: Set Up Development Environment
```bash
# Update system first
sudo nixos-rebuild switch --upgrade

# Add development tools to configuration
sudo vim /etc/nixos/configuration.nix
```

Add to `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  vim
  wget
  curl
  git
  htop
  # Development essentials for Claude Code
  nodejs
  nodePackages.npm
  python3
  python3Packages.pip
  unzip
  which
];
```

Apply changes:
```bash
sudo nixos-rebuild switch
```

### Step 2: Install Claude Code

**CRITICAL**: The standard `npm install -g` approach fails in NixOS due to read-only Nix store. Use the NixOS-specific approach below.

**NixOS Method (Recommended)**
```bash
# Add Claude Code to system packages in configuration
sudo vim /etc/nixos/configuration.nix
```

Add to `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  vim
  wget
  curl
  git
  htop
  # Development essentials
  nodejs
  nodePackages.npm
  python3
  python3Packages.pip
  unzip
  which
  # Claude Code installation
  nodePackages."@anthropic-ai/claude-code"
];
```

Apply the configuration:
```bash
sudo nixos-rebuild switch
```

**Alternative: User-level Installation**
If the package isn't available in nixpkgs, use local installation:
```bash
# Create local npm directory
mkdir -p ~/.local/lib/node_modules
mkdir -p ~/.local/bin

# Set npm prefix to local directory
npm config set prefix ~/.local

# Add to PATH in shell profile
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install Claude Code locally
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

### Step 3: Initial Claude Code Configuration
```bash
# Create project directory for system configuration
mkdir -p ~/nixos-config
cd ~/nixos-config

# Initialize git repository for configuration tracking
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Copy current system configuration
cp -r /etc/nixos/* .
git add .
git commit -m "Initial base system configuration"

# Create CLAUDE.md for project context
```

Create `~/nixos-config/CLAUDE.md`:
```markdown
# NixOS System Configuration Project

## Project Goal
Complete the System76 Kudu6 LLM-optimized Linux build based on the synthesis of 10 LLM responses.

## Current State
- ✅ Base NixOS system installed and functional
- ✅ Claude Code installed and ready
- ⏳ Ready for Phase 2+ implementation

## Next Steps (for Claude Code to handle)
1. Implement Hyprland + Wayland configuration
2. Set up NVIDIA drivers and hybrid graphics
3. Configure gaming layer (Steam, WINE, Proton)
4. Set up development environment
5. Install AI/ML stack with CUDA support
6. Configure cloud development tools

## Reference Documents
- `/home/chris/projects/human-oriented-environment/llm-optimized-linux-build-plan.md` - Complete build plan
- `/home/chris/projects/human-oriented-environment/llm-responses/` - Original LLM recommendations

## Critical System Info
- Hardware: System76 Kudu6 (Intel i7-10750H, 64GB RAM, RTX 3060)
- Current OS: NixOS 24.05
- Filesystem: XFS root, EFI boot
- User: chris (wheel group, sudo enabled)

## Confirmation Points
Claude Code should request confirmation before:
1. Major system changes (kernel, drivers, display server)
2. Graphics driver installation/configuration
3. Bootloader modifications
4. Network/firewall changes
5. Any potentially system-breaking changes
```

## Phase 3: Handoff to Claude Code

### Final Checklist Before Handoff
- [X] NixOS base system boots successfully
- [X] Network connectivity functional
- [X] User account has sudo access
- [X] Claude Code installed and operational
- [X] Project directory created with git tracking
- [X] CLAUDE.md context file created
- [X] Reference documents accessible

### Handoff Command
```bash
cd ~/nixos-config
claude
```

Then provide Claude Code with this instruction:

> "Please implement the next phases of the LLM-optimized Linux build plan, starting with Hyprland/Wayland configuration. Reference the complete build plan at `/home/chris/projects/human-oriented-environment/llm-optimized-linux-build-plan.md` and request my confirmation before any major system changes. Work systematically through each phase, testing functionality at each step."

## Emergency Recovery

### If Something Goes Wrong
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or boot into previous generation from GRUB menu
# Select "NixOS - Configuration X (previous)"

# Check system generations
sudo nix-env --list-generations --profile /nix/var/nix-profiles/system

# Rollback to specific generation
sudo nix-env --profile /nix/var/nix-profiles/system --rollback
sudo nixos-rebuild switch
```

### Recovery Boot
If system won't boot:
1. Boot from NixOS USB installer
2. Mount filesystems as in installation
3. Examine `/mnt/etc/nixos/configuration.nix`
4. Fix configuration and reinstall if necessary

## Success Criteria for Base System
- System boots to login prompt
- Network connectivity works
- User can log in and sudo
- Claude Code launches successfully
- Git repository functional for tracking changes
- Ready for Claude Code to continue automated build

This establishes a minimal but solid foundation for Claude Code to build upon, with all the essential tools and safety mechanisms in place.